$namespaces:
  arv: "http://arvados.org/cwl#"
  cwltool: "http://commonwl.org/cwltool#"
cwlVersion: v1.0
class: Workflow
label: Filters gVCFs by some quality cutoff
doc: |
    Takes in gVCFs, and using the defined cutoff integer as a quality cutoff, filters out variant calls that do not meet the cutoff specified.
requirements:
  - class: DockerRequirement
    dockerPull: javatools
  - class: ResourceRequirement
    coresMin: 2
    coresMax: 2
  - class: ScatterFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: SubworkflowFeatureRequirement
hints:
  arv:RuntimeConstraints:
    keep_cache: 4096
  cwltool:LoadListingRequirement:
    loadListing: shallow_listing

inputs:
  datafilenames:
    type: File[]
    label: Directories of gVCF chromosome files
  datafilepdh:
    type: File[]
    label: List of portable data hashes (pdh) in Arvados
  bashscript:
    type: File
    label: Master bash script to control filtering
  filter_gvcf:
    type: File
    label: Compiled code that filters gVCFs
  cutoff:
    type: string
    label: Filtering cutoff threshold
outputs:
  out1:
    type: Directory[]
    outputSource: step2/out1
    label: Output directory of filtered gVCFs

steps:
  step1:
    run: getCollections.cwl
    in:
      datafilenames: datafilenames
      datafilepdh: datafilepdh
    out: [fileprefix,collectiondir]
    label: Return Array of directory names and Array of directories containing gVCFs

  step2:
    scatter: [gffPrefix,gffDir]
    scatterMethod: dotproduct
    in:
      bashscript: bashscript
      gffDir: step1/collectiondir
      gffPrefix: step1/fileprefix
      filter_gvcf: filter_gvcf
      cutoff: cutoff
    run: filter.cwl
    out: [out1]
