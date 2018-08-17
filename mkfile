<| emptyenv s6-envdir config env

001-blastn/%.pre-mat.blastn.txt:	data/%.fa
	set -x
	mkdir -p "$(dirname "${target}")"
	query-sequences \
	| blast-header \
	> "${target}.build" \
	&& mv "${target}.build" "${target}"

002-plus-minus/%.realign.txt:	002-plus-minus/%.minus.rev-comp.blastn.txt	002-plus-minus/%.plus.txt
	set -x
	TMPDIR="`dirname ${target}`"
	mkdir -p "${TMPDIR}"
	minus="${TMPDIR}/${stem}.minus.rev-comp.blastn.txt"
	plus="${TMPDIR}/${stem}.plus.txt"
	cat $minus $plus \
	| awk 'BEGIN{FS=OFS="\t"} {print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12}' \
	> $target'.build' \
	&& mv $target'.build' $target

002-plus-minus/%.minus.rev-comp.blastn.txt:	002-plus-minus/%.minus.rev-comp.fa
	set -x
	mkdir -p `dirname "$target"`
	query-sequences \
	| choose-best-alignment \
	| blast-header \
	> $target'.build' \
	&& mv $target'.build' $target

002-plus-minus/%.minus.rev-comp.fa:	002-plus-minus/%.minus.fa
	set -x
	mkdir -p `dirname "$target"`
	fastx_reverse_complement \
		-i $prereq \
		-o /dev/fd/1 \
	> $target'.build' \
	&& mv $target'.build' $target

002-plus-minus/%.minus.fa:	002-plus-minus/%.minus.txt
	set -x
	mkdir -p `dirname "$target"`
	grep -A1 \
		-f <(awk '{print $1}' $prereq) \
		$QUERYFASTA \
	| sed '/--/d' \
	| sed 's/U/T/g' \
	> $target'.build' \
	&& mv $target'.build' $target

'002-plus-minus/(.*)\.(plus|minus).txt':R:	'002-plus-minus/\1.best-alignment.txt'
	set -x
	mkdir -p `dirname "$target"`
	TMPFILE="${target}.build"
	grep "$stem2" $prereq  \
	> "${target}.build" \
	|| test 1 -eq "$?" && true \
	&& mv "${TMPFILE}" "${target}"

002-plus-minus/%.best-alignment.txt:	data/%.txt
	set -x
	mkdir -p `dirname "$target"`
	choose-best-alignment $prereq \
	> $target'.build' \
	&& mv $target'.build' $target

#Añadiendo aquellas secuencias que no alinearon en blastn
002-short-sequences/%.final_mismatch.txt:	002-short-sequences/%.extended_mismatches.debug1.txt
	set -x
	mkdir -p `dirname "$target"`
	handle-unaligned "${prereq}" \
	> $target'.build' \
	&& mv $target'.build' $target

#Solucion temporal a los casos cuando el query alinea en los extremos del subject
002-short-sequences/%.extended_mismatches.debug1.txt:	002-short-sequences/%.extended_mismatches.txt
	set -x
	mkdir -p `dirname "$target"`
	correct-mismatches \
		$prereq \
	| sort-by-least-mismatch \
	> $target'.build' \
	&& mv $target'.build' $target

002-short-sequences/%.extended_mismatches.txt:	002-short-sequences/%.noprocessing.txt	002-short-sequences/%.sequenceadded.txt
	set -x
	mkdir -p `dirname "$target"`
	{
	cat $prereq \
	| grep -v ">" \
	| awk \
		'BEGIN{FS=OFS="\t"} \
		{print $0, $5+$6+$21}' \
	| awk '!seen[$1]++' \
	| sort-by-least-mismatch \
	| ea-header
	} > $target'.build' \
	&& mv $target'.build' $target

002-short-sequences/%.sequenceadded.txt:	002-short-sequences/%.forprocessing.txt
	set -x
	mkdir -p `dirname "$target"`
	extend-alignment $prereq \
	> $target'.build' \
	&& mv $target'.build' $target

002-short-sequences/%.noprocessing.txt: 002-short-sequences/%.querylength.txt
	set -x
	mkdir -p `dirname "$target"`
        awk 'BEGIN {FS="\t"; OFS="\t"} $4 == $13 {print $0,"NA","NA","NA","NA", "NA", "NA", 0}' $prereq \
        | tr -s "\t" > $target'.build' \
        && mv $target'.build' $target

002-short-sequences/%.forprocessing.txt:	002-short-sequences/%.querylength.txt
	set -x
	mkdir -p `dirname "$target"`
	awk 'BEGIN {FS="\t"; OFS="\t"} $4 < $13 {print $0}' $prereq \
	> $target'.build' \
        && mv $target'.build' $target

002-short-sequences/%.querylength.txt: 002-short-sequences/%.noheader.txt $QUERYFASTA 002-short-sequences/%.subjectlength.txt
	set -x
	mkdir -p `dirname "$target"`
	SUBJECT="002-short-sequences/${stem}.subjectlength.txt"
	SEQUENCES="002-short-sequences/${stem}.noheader.txt"
	query-and-subject-length "${SUBJECT}" "${SEQUENCES}" \
	> $target'.build' \
	&& mv $target'.build' $target

002-short-sequences/%.noheader.txt:	data/%.txt
	set -x
	mkdir -p `dirname "$target"`
	tail -n+2 $prereq > $target'.build' \
	&& mv $target'.build' $target

002-short-sequences/%.subjectlength.txt:	$SUBJECTFASTA
	query-length ${prereq} \
	> $target'.build' \
        && mv $target'.build' $target

#Añadiendo aquellas secuencias que no alinearon en blastn
002-short-sequences/%.final_mismatch.txt:	002-short-sequences/%.extended_mismatches.debug1.txt
	set -x
	mkdir -p `dirname "$target"`
	handle-unaligned "${prereq}" \
	> $target'.build' \
	&& mv $target'.build' $target

#Solucion temporal a los casos cuando el query alinea en los extremos del subject
002-short-sequences/%.extended_mismatches.debug1.txt:	002-short-sequences/%.extended_mismatches.txt
	set -x
	mkdir -p `dirname "$target"`
	correct-mismatches \
		$prereq \
	| sort-by-least-mismatch \
	> $target'.build' \
	&& mv $target'.build' $target

002-short-sequences/%.extended_mismatches.txt:	002-short-sequences/%.noprocessing.txt	002-short-sequences/%.sequenceadded.txt
	set -x
	mkdir -p `dirname "$target"`
	{
	cat $prereq \
	| grep -v ">" \
	| awk \
		'BEGIN{FS=OFS="\t"} \
		{print $0, $5+$6+$21}' \
	| awk '!seen[$1]++' \
	| sort-by-least-mismatch \
	| ea-header \
	} \
	> $target'.build' \
	&& mv $target'.build' $target

002-short-sequences/%.sequenceadded.txt:	002-short-sequences/%.forprocessing.txt
	set -x
	mkdir -p `dirname "$target"`
	extend-alignment $prereq \
	> $target'.build' \
	&& mv $target'.build' $target

002-short-sequences/%.noprocessing.txt: 002-short-sequences/%.querylength.txt
	set -x
	mkdir -p `dirname "$target"`
        awk 'BEGIN {FS="\t"; OFS="\t"} $4 == $13 {print $0,"NA","NA","NA","NA", "NA", "NA", 0}' $prereq \
        | tr -s "\t" > $target'.build' \
        && mv $target'.build' $target

002-short-sequences/%.forprocessing.txt:	002-short-sequences/%.querylength.txt
	set -x
	mkdir -p `dirname "$target"`
	awk 'BEGIN {FS="\t"; OFS="\t"} $4 < $13 {print $0}' $prereq \
	> $target'.build' \
        && mv $target'.build' $target

002-short-sequences/%.querylength.txt: 002-short-sequences/%.noheader.txt $QUERYFASTA 002-short-sequences/%.subjectlength.txt
	set -x
	mkdir -p `dirname "$target"`
	SUBJECT="002-short-sequences/${stem}.subjectlength.txt"
	SEQUENCES="002-short-sequences/${stem}.noheader.txt"
	query-and-subject-length "${SUBJECT}" "${SEQUENCES}" \
	> $target'.build' \
	&& mv $target'.build' $target

002-short-sequences/%.noheader.txt:	data/%.txt
	set -x
	mkdir -p `dirname "$target"`
	tail -n+2 $prereq > $target'.build' \
	&& mv $target'.build' $target

002-short-sequences/%.subjectlength.txt:	$SUBJECTFASTA
	query-length "${prereq}" \
	> $target'.build' \
        && mv $target'.build' $target

## Add a column for: Total mismatches (will be the sum of blastn reported mm + gapopen + extended mismatches)
## Add a column for: extended mismatches (produced by comparing char by char, the concantenated query 5+3 extensions vs the concatenated subject 5+3 extensions )
003-long-sequences-extend-blast/%.total_mismatches.txt:Q: 003-long-sequences-extend-blast/%.extended.txt
	awk ' BEGIN { FS=OFS="\t"}
		NR == 1 {print "total_mismatches(extended+mismatch+gapopen)","extended_mismatches", $0 }
		NR != 1 {
			## concatenate extended nucleotides by query, or by subject
			Q_EXTENSION=$1$2
			S_EXTENSION=$3$4
			## Split the extended nucleotides by character into an array
			split(Q_EXTENSION, Qnucleotides, "")
			split(S_EXTENSION, Snucleotides, "")
			## restart the mismatch variable
			extended_mismatch=0
			## loop trough the nucleotide arrays and compare by position
			for (i=1; i <= length(Q_EXTENSION); i++) {
				if ( Qnucleotides[i] != Snucleotides[i] )
					extended_mismatch++
			}
			total_mismatch=(extended_mismatch + $8 + $9)
			print total_mismatch, extended_mismatch, $0
		} ' $prereq > $target.build \
		&& mv $target.build $target

## Create columns wih the nucleotide sequences of the 5' and 3' extended regions, both for the query sequence and the subject sequence
003-long-sequences-extend-blast/%.extended.txt:Q: 003-long-sequences-extend-blast/%.best_hit.txt
	extend-mismatches $prereq \
	> $target.build \
	&& mv $target.build $target

003-long-sequences-extend-blast/%.best_hit.txt: 003-long-sequences-extend-blast/%.txt
	echo "getting best hits"
	sort -k17,17 $prereq \
	| awk '!seen[$17]++' \
	> $target.build \
	&& mv $target.build $target

###ExtendAlign-Long Sequences###
#
#Añadiendo aquellas secuencias que no alinearon en blastn
003-long-sequences/%.final_mismatch.txt:	003-long-sequences/%.extended_mismatches.txt
	set -x
	mkdir -p `dirname "$target"`
	handle-unaligned "${prereq}" \
	 > $target'.build' \
	&& mv $target'.build' $target

003-long-sequences/%.extended_mismatches.txt:	003-long-sequences/%.noprocessing.txt 003-long-sequences/%.sequenceadded.txt
	set -x
	mkdir -p `dirname "$target"`
	{
	cat $prereq | grep -v ">" \
	| awk \
		'BEGIN{FS=OFS="\t"} \
		{print $0, $5+$6+$21}' \
	| awk '!seen[$1]++' \
	| sort-by-least-mismatch \
	| ea-header
	} > $target'.build' \
	&& mv $target'.build' $target

003-long-sequences/%.sequenceadded.txt:	003-long-sequences/%.forprocessing.txt
	set -x
	mkdir -p `dirname "$target"`
	extend-alignment $prereq \
	> $target'.build' \
	&& mv $target'.build' $target

003-long-sequences/%.noprocessing.txt: 003-long-sequences/%.querylength.txt
	set -x
	mkdir -p `dirname "$target"`
        awk 'BEGIN {FS="\t"; OFS="\t"} $4 == $13 {print $0,"NA","NA","NA","NA", "NA", "NA", 0}' $prereq \
        | tr -s "\t" > $target'.build' \
        && mv $target'.build' $target

003-long-sequences/%.forprocessing.txt:	003-long-sequences/%.querylength.txt
	set -x
	mkdir -p `dirname "$target"`
	awk 'BEGIN {FS="\t"; OFS="\t"} $4 < $13 {print $0}' $prereq \
	> $target'.build' \
        && mv $target'.build' $target

003-long-sequences/%.querylength.txt: 003-long-sequences/%.noheader.txt $QUERYFASTA 003-long-sequences/%.subjectlength.txt
	set -x
	mkdir -p `dirname "$target"`
	SUBJECT="003-long-sequences/${stem}.subjectlength.txt"
	SEQUENCES="003-long-sequences/${stem}.noheader.txt"
	query-and-subject-length "${SUBJECT}" "${SEQUENCES}" \
	> $target'.build' \
	&& mv $target'.build' $target

003-long-sequences/%.noheader.txt:	data/%.txt
	set -x
	mkdir -p `dirname "$target"`
	tail -n+2 $prereq > $target'.build' \
	&& mv $target'.build' $target

003-long-sequences/%.subjectlength.txt:	$SUBJECTFASTA
	query-length "${prereq}" \
	> $target'.build' \
        && mv $target'.build' $target