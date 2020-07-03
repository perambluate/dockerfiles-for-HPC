#!/bin/bash
TASK=MNLI
SOURCE=nvidia
MODEL=uncased
MPI=open
NP=1
LOG=${TASK}_${SOURCE}_${MODEL}_${MPI}
ERR=0

ReadInput(){
	while [[ -n $@ ]]; do
    	temp=$1
    	case ${temp%%=*} in
        	"code")
            	SOURCE=${SOURCE:-${temp#code=}};;
        	"model")
	            MODEL=${MODEL:-${temp#model=}};;
			"outdir")
				OUTDIR=${OUTDIR:-${temp#outdir=}};;
	    	"mpi")
				MPI=${MPI:-${temp#mpi=}};;
			"np")
				NP=${NP:-${temp#np=}};;
			"mpi_arg")
				MPI_ARG=${MPI_ARG:-${temp#mpi_arg=}};;
        	*)
            	echo "Wrong input, please input as following"
				echo "code=<using_nvidia_or_google_github> \
					model=<the_pretrained_model_for_fine_tuning> \
					mpi=<the_version_of_mpi_to_run> \
					np=<number_of_processes_to_run>
					mpi_arg=<the_arguments_for_mpirun>"
	            # exit 1;;
    	esac
	    shift
	done
}

ModuleLoad(){
	MPI_MODULE=mpi/${MPI}
	[[ ${MODEL%%_*} == 'wwm' ]] && BERT_MODULE=bert/${SOURCE}/large/wwm/${MODEL#*_}/${TASK} || BERT_MODULE=bert/${SOURCE}/large/${MODEL#*_}/${TASK}
	module purge && \
	module load ${MPI_MODULE} && \
	module load ${BERT_MODULE}
	ErrHandle $? 'ModuleLoad'
}

SetMPIExec(){
	if (( NP > 1 )); then
		[[ ${MPI} == 'open' ]] && ROOT_ALLOW='--allow-run-as-root' || ROOT_ALLOW=
		MPIEXEC='mpirun'${ROOT_ALLOW}'-np '${NP}' '${MPI_ARG}
	else
		MPIEXEC=
	fi
}

ErrHandle(){
	ERR=${ERR:-$1}
	BLOCK=$2
	if [[ $1 != 0 ]]; then
        printf "Some errors occurred in %s, please fix it and modify the script!!\n" ${BLOCK}
        # exit 1;
    fi
}

ReadInput $@
ModuleLoad
SetMPIExec
OUTDIR=results/${LOG}
[ -d ${OUTDIR} ] || mkdir -p ${OUTDIR}

time -p \
${MPIEXEC} \
python ${CODE_PATH}/run_classifier.py \
--do_train=true \
--do_eval=false \
--do_predict=false \
--do_lower_case=false \
--task_name=${TASK} \
--data_dir=${DATA_PATH} \
--vocab_file=${MODEL_PATH}/vocab.txt \
--bert_config_file=${MODEL_PATH}/bert_config.json \
--init_checkpoint=${MODEL_PATH}/bert_model.ckpt \
--output_dir=${OUTDIR} \
--learning_rate=5e-5 \
--num_train_epochs=0.001 \
--max_seq_length=128 \
--train_batch_size=1 \
--num_accumulation_steps=1 \
--save_checkpoints_steps=1000 \
--warmup_proportion=0.1 \
--use_fp16 \
--horovod \
2>&1 | tee ${LOG}.log