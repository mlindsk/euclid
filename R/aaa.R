validate_constructor_input <- function(..., .convert_numerics = TRUE) {
  inputs <- lapply(list(...), function(x) {
    if (.convert_numerics && !is_geometry(x) && is.numeric(x)) {
      x <- as_exact_numeric(x)
    }
    x
  })
  dim <- unique(unlist(lapply(inputs, dim)))
  if (length(dim) > 1) {
    rlang::abort("Inputs must be of the same dimensionality")
  }
  input_lengths <- lengths(inputs)
  if (length(input_lengths) == 0 || any(lengths(input_lengths)) == 0) {
    return(list())
  }
  max_length <- max(input_lengths)
  if (any(input_lengths != 1 & input_lengths != max_length)) {
    rlang::abort("Inputs must be either scalar or of the same length")
  }
  inputs[input_lengths == 1] <- lapply(inputs[input_lengths == 1], function(x) {
    rep_len(x, max_length)
  })
  inputs
}

get_ptr <- function(x) .subset2(x, 1L)

restore_euclid_vector <- function(x, old) {
  x <- list(x)
  attributes(x) <- attributes(old)
  x
}
