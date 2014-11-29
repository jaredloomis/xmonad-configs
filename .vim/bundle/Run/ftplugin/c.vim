if &filetype != "cpp"
    command! Run execute "!gcc % && ./%:r"
endif
