--------------------------------------------------------------------------------
1. submission_summary.txt
--------------------------------------------------------------------------------

Recopilatorio de todos los registros de "variantes -> fenotipos" subidos a ClinVar. Se trata del archivo en el cual el script hace
las búsquedas principales, a fin de obtener los registros que nos interesen.

1.  VariationID:              El identificador que ClinVar asigna a los sets de variantes genéticas registradas.
2.  ClinicalSignificance:     Interpretación clínica de la relación variante-fenotipo (patogénica, benigna, etc).
3.  DateLastEvaluated:        La última fecha en la que el usuario que subió el registro evaluó dicha relación variante-fenotipo.
4.  Description:              Descripción opcional de la base científica subyacente a la interpretación de la relación variante-fenotipo.
5.  SubmittedPhenotypeInfo:   Nombres o identificadores que el usuario ha utilizado para describir el/los fenotipo(s) relacionado(s) con la variante.
6.  ReportedPhenotypeInfo:    La combinación "identificador/nombre" de MedGen que ClinVar le asigna al fenotipo relacionado con la variante. Se asigna
			      "na" cuando el fenotipo no tiene identificador/nombre en MedGen.
7.  ReviewStatus:             El nivel de curación del registro, concretamente en lo referente a la interpretación clínica de la relación 
			      variante-fenotipo (http://www.ncbi.nlm.nih.gov/clinvar/docs/variation_report/#review_status). 
8.  CollectionMethod:         El método por el cual el usuario que subió el registro obtuvo la información proporcionada.
9.  OriginCounts:             Origen del alelo (somatico o linea germinal) y número de veces que se ha visto dicho origen.
10. Submitter:                El nombre del usuario (entidad) que ha subido el registro.
11. SCV:                      El identificador (Accession number) que ClinVar asigna al registro subido por el usuario. Cada registro tiene su 
		              "SCV" asociado, pero registros que describen una misma relación variante-fenotipo se recogen bajo un identificador "RCV".
12. SubmittedGeneSymbol:      El símbolo del gen que se ve afectado por la variante según el usuario que ha subido el registro. Puede ser null.




--------------------------------------------------------------------------------
2. variant_summary.txt
--------------------------------------------------------------------------------

Una recopilación de datos relacionados a cada una de las diferentas variantes genéticas localizadas en algún punto del genoma para las cuales se haya
subido información a ClinVar. Este archivo es utilizado por el script para hacer la conversión del nombre de las variantes a su correspondiente VariationID.

1.  AlleleID               Número asignado a cada una de las variantes individuales subidas a ClinVar. La diferencia respecto a VariationID
                           está en que un VariationID puede recoger varios AlleleID (por ejemplo, en el caso de haplotipos)
2.  Type                   El tipo de variante representada por el AlleleID.
3.  Name                   El nombre asignado por ClinVar para el registro asociado al AlleleID.
4.  GeneID                 GeneID de NCBI del gen asociado a la variante, en caso de haber solo un gen. Se indica -1 en cualquier otro caso.
5.  GeneSymbol             "Nombre" del gen asociado. En caso de que una variante solape con varios genes, se listan separados por coma.
6.  HGNC_ID                String de formato HGNC:número, dada si solo hay un GeneID, apareciendo '-' en cualquier otro caso.
7.  ClinicalSignificance   Interpretación clínica de la variante (patogénica, benigna, etc). Dado que diferentes registros pueden referirse a
			   una misma relación variante-fenotipo, pero indicar una interpretación clínica diferente, se le da prioridad a aquellos
			   registros que cuentan con un mayor nivel de curación a la hora de determinar lo que aparece en esta columna.
8.  ClinSigSimple          0 = cuando no hay registros asociados a la variante clasificados como Likely pathogenic o Pathogenic;
                           1 = cuando almenos hay un registro clasificado como Likely pathogenic o Pathogenic;
                          -1 = cuando no hay ningun dato referente a la intepretación clínica para la variante/set de variantes.
9.  LastEvaluated          La última fecha en la que cualquier usuario especificó una interpretación clínica para la variante/set de variantes.
10. RS# (dbSNP)            RS# en dbSNP, "-1" si falta.
11. nsv/esv (dbVar)        El identificador NSV para la región genómica en dbVar
12. RCVaccession           Lista de los identificadores RCV asociados a la variante. Estos identificadores agrupan todos los registros que asocien 
			   una misma variante/set de variantes a un mismo fenotipo. Por tanto, si una variante/set de variantes ha sido asociado a 3 fenotipos diferentes
			   en tres registros diferentes, una misma VariationID tendrá 3 RCV asociados.
13. PhenotypeIDs           Lista de identificadores para el/los fenotipo(s) asociado(s) a la variante/set de variantes.
14. PhenotypeList          Lista de nombres que se corresponden con los PhenotypeIDs.
15. Origin                 Lista de todos los origenes alélicos para la variante.
16. OriginSimple           Parecido a Origin, pero hace mas simple la distinción entre un origen de linea germinal y uno somático.
17. Assembly               Nombre del assembly en el cual las localizaciones de las variantes están basados (GRCh37 o GRCh38) . 
18. ChromosomeAccession    Accession number de la secuencia RefSeq que define las posiciones de start y stop de la variante, encontradas en las siguientes columnas. 
19. Chromosome             Localización en el cromosoma de la variante.
20. Start                  Posición en la secuencia del cromosoma en la que empieza la variante, en orientación pter->qter.
21. Stop                   Posición en la secuencia del cromosoma en la que termina la variante, en orientación pter->qter.
22. ReferenceAllele        El alelo de referencia según el standard vcf.
23. AlternateAllele        El alelo alternativo según el standard vcf.
24. Cytogenetic            La banda del cromosoma en nomenclatura ISCN.
25. ReviewStatus           Muestra el mayor nivel de curación encontrado para los registros asociados a esa variante.
26  NumberSubmitters       Número de entidades (usuarios) que han registrado información sobre esa variante.
27. Guidelines             Si el gen aparece en alguna guía de ACMG, se indica la versión de dicha guia.  
28. TestedInGTR            Y/N (Yes/No) si hay un registro específico para esta variante en el NIH Genetic Testing Registry (GTR). 
29. OtherIDs               Lista de identificadores o fuentes de información relacionadas con la variante.
30. SubmitterCategories    Código de valores que indican si el usuario que subió el registro  (1), cualquier otro tipo de fuente (2) o ambas (3).
31. VariationID            El identificador que ClinVar asigna a los sets de variantes genéticas registradas.



--------------------------------------------------------------------------------
3. MedGen_HPO_OMIM_Mapping.txt
--------------------------------------------------------------------------------

Recopilación de las relaciones entre términos HPO y CUI de MedGen/IDs de OMIM. Las relaciones son sacadas de HPO.
Este archivo es utilizado por el script para obtener los HPOs relacionados con las enfermedades/fenotipos asociados a una variante.


1.  OMIM_CUI: 	   Identificador único asignado por MedGen a un registro de OMIM.
2.  MIM_number:	   Identificador propio de OMIM asignado a un registro.
3.  OMIM_name: 	   Nombre del término utilizado por OMIM (nombre de la enfermedad).	 
4.  Relationship:  Relación del término HPO con el registro de OMIM.
5.  HPO_CUI: 	   CUI asignado al término HPO por MedGen.
6.  HPO_ID:        Identificador propio de HPO para referirse a un término.
7.  HPO_name: 	   Nombre del término HPO.
8.  MedGen_name:   Nombre del término en MedGen.
9.  MedGen_source: Fuente del término usado preferentemente por MedGen.
10. STY: 	   Semantic type.



--------------------------------------------------------------------------------
4. variant_allele.txt
--------------------------------------------------------------------------------

En este archivo encontramos un mapeo de las VariantIDs y sus AlleleID asociados.

1. VariationID:            El identificador que ClinVar asigna a los sets de variantes genéticas registradas.
2. Type:                   Tipos de variante: Variant (variante simple), Haplotype, CompoundHeterozygote, Complex, Phase unknown, Distinct chromosomes
3. AlleleID:               Número asignado a cada una de las variantes individuales subidas a ClinVar.
4. Interpreted:            _yes_ indica que una intepretacion sobre la variante ha sido subida a Clinvar,
                           _no_ indica que información sobre esa variante ha sido subida como parte de otro record.

Curiosidades:

	-	Cuando la variante se trata, por ejemplo, de un Haplotipo, aparecerán tantas filas como alelos diferentes compongan esa variante, repitiendose
		por tanto el VariantID

	-	En el caso de un alelo que forma parte de un heterozigoto para el cual se ha dado una descripción (significancia clínica, fenotipo asociado
		etc), pero que no se ha subido un record específico sobre ese alelo individual, tendremos dos líneas en el archivo: una para la variante tipo
		"heterozigoto", con su VariantID e interpreted = yes, y otra para el alelo individual, con un VariantID diferente e interpreted = no. 
		El AlleleID es el mismo, repitiendose en las dos lineas.

	-	Un VariantID y un AlleleID pueden tener exactamente la misma combinación de numeros, siendo indistinguibles.