let safeFlags = "-j4 -O2 -flate-dmd-anal -funfolding-use-threshold=16 -fmax-simplifier-iterations=10 -Wall"
let llvmFlags = "-fllvm -optlc=-O4 -optlo=-O3"
" let unsafeLlvmFlags = "-optlc='-aa-eval -adce'"
let parallelFlags = "-threaded -feager-blackholing"
let parallelFlagsRts = "-N"

" Interactive GHCi prompt.
command! Runi execute "!ghci %"

" Run, recomp, safe flags only.
command! Run execute "!ghc -fforce-recomp " . safeFlags . " % && ./%:r"

" Run fast, no recomp, safe flags only.
command! Runf execute "!ghc " . safeFlags . " % && ./%:r"

" Run LLVM, recomp, safe flags only.
command! Runl execute "!ghc -fforce-recomp " . safeFlags . " " . llvmFlags . " -Wall % && ./%:r"

" Run parallel, recomp, safe flags only.
command! Runp execute "!ghc -fforce-recomp -rtsopts " . safeFlags . " " . parallelFlags . " % && ./%:r +RTS " . parallelFlagsRts . " -RTS"

" Other flags?: -ndp
