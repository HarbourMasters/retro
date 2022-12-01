enum ResourceType {
  // Common
  archive(0x4F415243), // OARC (UNUSED)
  displayList(0x4F444C54), // ODLT
  vertex(0x4F565458), // OVTX
  matrix(0x4F4D5458), // OMTX
  array(0x4F415252), // OARR
  blob(0x4F424C42), // OBLB
  texture(0x4F544558), // OTEX

  // SoH
  sohAnimation(0x4F414E4D), // OANM
  sohPlayerAnimation(0x4F50414D), // OPAM
  sohRoom(0x4F524F4D), // OROM
  sohCollisionHeader(0x4F434F4C), // OCOL
  sohSkeleton(0x4F534B4C), // OSKL
  sohSkeletonLimb(0x4F534C42), // OSLB
  sohPath(0x4F505448), // OPTH
  sohCutscene(0x4F435654), // OCUT
  sohText(0x4F545854), // OTXT
  sohAudio(0x4F415544), // OAUD
  sohAudioSample(0x4F534D50), // OSMP
  sohAudioSoundFont(0x4F534654), // OSFT
  sohAudioSequence(0x4F534551); // OSEQ

  const ResourceType(this.value);
  final int value;
}
