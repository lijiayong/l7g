$namespaces:
  arv: "http://arvados.org/cwl#"
  cwltool: "http://commonwl.org/cwltool#"
cwlVersion: v1.0
class: CommandLineTool
label: Filters gVCFs by a specified quality cutoff and cleans
requirements:
  DockerRequirement:
    dockerPull: arvados/l7g
  ResourceRequirement:
    coresMin: 2
    ramMin: 8000
  ShellCommandRequirement: {}
hints:
  arv:RuntimeConstraints:
    keep_cache: 4096
inputs:
  gvcf:
    type: File
    label: Input gVCF file
    secondaryFiles: [.tbi]
  filtergvcf:
    type: File
    label: Code that filters gVCFs
    default:
      class: File
      location: src/filter-gvcf
  cutoff:
    type: int
    label: Filtering cutoff threshold
  keepgqdot:
    type: boolean?
    label: Flag for keeping GQ represented by "."
  cleanvcf:
    type: File
    label: Code that cleans gVCFs
    default:
      class: File
      location: src/cleanvcf.py
outputs:
  filteredcleangvcf:
    type: File
    label: Filtered and clean gVCF
    outputBinding:
      glob: "*vcf.gz"
    secondaryFiles: [.tbi]
baseCommand: zcat
arguments:
  - $(inputs.gvcf)
  - shellQuote: false
    valueFrom: "|"
  - $(inputs.filtergvcf)
  - prefix: "-k"
    valueFrom: $(inputs.keepgqdot)
  - $(inputs.cutoff)
  - shellQuote: false
    valueFrom: "|"
  - $(inputs.cleanvcf)
  - shellQuote: false
    valueFrom: "|"
  - "bgzip"
  - "-c"
  - shellQuote: false
    valueFrom: ">"
  - $(inputs.gvcf.nameroot).gz
  - shellQuote: false
    valueFrom: "&&"
  - "tabix"
  - prefix: "-p"
    valueFrom: "vcf"
  - $(inputs.gvcf.nameroot).gz
