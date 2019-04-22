$namespaces:
  arv: "http://arvados.org/cwl#"
  cwltool: "http://commonwl.org/cwltool#"
cwlVersion: v1.0
class: Workflow
label: Convert gVCFs to FastJ
requirements:
  DockerRequirement:
    dockerPull: arvados/l7g
  ScatterFeatureRequirement: {}
hints:
  arv:RuntimeConstraints:
    keep_cache: 4096
inputs:
  gvcfdir:
    type: Directory
    label: Input gVCF directory
  ref:
    type: string
    label: Reference genome
  reffa:
    type: File
    label: Reference genome in FASTA format
  afn:
    type: File
    label: Compressed assembly fixed width file
  aidx:
    type: File
    label: Assembly index file
  refM:
    type: string
    label: Mitochondrial reference genome
  reffaM:
    type: File
    label: Reference mitochondrial genome in FASTA format
  afnM:
    type: File
    label: Compressed mitochondrial assembly fixed width file
  aidxM:
    type: File
    label: Mitochondrial assembly index file
  seqidM:
    type: string
    label: Mitochondrial naming scheme
  tagset:
    type: File
    label: Compressed tagset in FASTA format

outputs:
  fjdirs:
    type: Directory[]
    label: Output FastJ directories
    outputSource: gvcf2fastj/fjdir

steps:
  getfiles:
    run: getfiles.cwl
    in:
      gvcfdir: gvcfdir
    out: [gvcfs]

  gvcf2fastj:
    run: gvcf2fastj.cwl
    scatter: gvcf
    in:
      gvcf: getfiles/gvcfs
      ref: ref
      reffa: reffa
      afn: afn
      aidx: aidx
      refM: refM
      reffaM: reffaM
      afnM: afnM
      aidxM: aidxM
      seqidM: seqidM
      tagset: tagset
    out: [fjdir]
