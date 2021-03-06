#' Vector of circles
#'
#' This function create circles from various combinations of input.
#'
#' @param ... Various input. See the Constructor section.
#' @param default_dim The dimensionality when constructing an empty vector
#' @param x A circle vector or an object to convert to it
#'
#' @return An `euclid_circle` vector
#'
#' @section Constructors:
#' **2 dimensional circles**
#' - Providing one point and one numeric vector will construct circles centered
#'   at the point with the **squared** radius given by the numeric.
#' - Providing two point vectors will construct circles centered between the two
#'   points with a radius of half the distance between the two points.
#' - Providing three point vectors will construct the unique circle that pass
#'   through the three points.
#'
#' @export
#'
#' @examples
#' ## 2 Dimensions
#'
#' point1 <- point(runif(5), runif(5))
#' point2 <- point(runif(5), runif(5))
#' point3 <- point(runif(5), runif(5))
#' number <- exact_numeric(1:5)
#'
#' # Construction with center and radius
#' circle(point1, number)
#'
#' # integers and numerics are converted automatically
#' circle(point1, 1:5)
#'
#' # You are free to name the input for readability
#' circle(center = point1, radius = number)
#'
#' # Construction with 2 points
#' circle(point1, point2)
#'
#' # Construction with 3 points
#' circle(point1, point2, point3)
#'
circle <- function(..., default_dim = 2) {
  inputs <- validate_constructor_input(...)

  if (length(inputs) == 0) {
    return(new_circle_empty(default_dim))
  }

  points <- inputs[vapply(inputs, is_point, logical(1))]
  numbers <- inputs[vapply(inputs, is_exact_numeric, logical(1))]
  planes <- inputs[vapply(inputs, is_plane, logical(1))]
  vectors <- inputs[vapply(inputs, is_vec, logical(1))]
  spheres <- inputs[vapply(inputs, is_sphere, logical(1))]

  if (length(points) == 3) {
    new_circle_from_3_points(points[[1]], points[[2]], points[[3]])
  } else if (length(points) == 2) {
    new_circle_from_2_points(points[[1]], points[[2]])
  } else if (length(points) == 1 && length(numbers) == 1 && length(planes) == 1) {
    new_circle_from_point_number_plane(points[[1]], numbers[[1]], planes[[1]])
  } else if (length(points) == 1 && length(numbers) == 1 && length(vectors) == 1) {
    new_circle_from_point_number_vec(points[[1]], numbers[[1]], vectors[[1]])
  } else if (length(points) == 1 && length(numbers) == 1) {
    new_circle_from_point_number(points[[1]], numbers[[1]])
  } else if (length(spheres) == 2) {
    new_circle_from_2_spheres(spheres[[1]], spheres[[2]])
  } else if (length(spheres) == 1 && length(planes) == 1) {
    new_circle_from_sphere_plane(spheres[[1]], planes[[1]])
  } else {
    rlang::abort("Don't know how to construct circles from the given input")
  }
}
#' @rdname circle
#' @export
is_circle <- function(x) inherits(x, "euclid_circle")

# Conversion --------------------------------------------------------------

#' @rdname circle
#' @export
as_circle <- function(x) {
  UseMethod("as_circle")
}
#' @export
as_circle.default <- function(x) {
  rlang::abort("Don't know how to convert the input to circles")
}
#' @export
as_circle.euclid_circle <- function(x) x

#' @export
as_sphere.euclid_circle3 <- function(x) {
  sphere(x)
}
#' @export
as_plane.euclid_circle3 <- function(x) {
  plane(x)
}

# Internal Constructors ---------------------------------------------------

new_circle2 <- function(x) {
  new_geometry_vector(x, class = c("euclid_circle2", "euclid_circle"))
}
new_circle3 <- function(x) {
  new_geometry_vector(x, class = c("euclid_circle3", "euclid_circle"))
}
new_circle_empty <- function(dim) {
  if (dim == 2) {
    new_circle2(create_circle_2_empty())
  } else {
    new_circle3(create_circle_3_empty())
  }
}
new_circle_from_point_number <- function(center, r) {
  if (dim(center) != 2) {
    rlang::abort("Circles in 3 dimensions cannot be constructed from center and radius")
  }
  new_circle2(create_circle_2_center_radius(get_ptr(center), get_ptr(r)))
}
new_circle_from_point_number_plane <- function(center, r, p) {
  new_circle3(create_circle_3_center_radius_plane(get_ptr(center), get_ptr(r), get_ptr(p)))
}
new_circle_from_point_number_vec <- function(center, r, v) {
  new_circle3(create_circle_3_center_radius_vec(get_ptr(center), get_ptr(r), get_ptr(v)))
}
new_circle_from_3_points <- function(p, q, r) {
  if (dim(p) == 2) {
    new_circle2(create_circle_2_3_point(get_ptr(p), get_ptr(q), get_ptr(r)))
  } else {
    new_circle3(create_circle_3_3_point(get_ptr(p), get_ptr(q), get_ptr(r)))
  }
}
new_circle_from_2_points <- function(p, q) {
  if (dim(p) != 2) {
    rlang::abort("Circles in 3 dimensions cannot be constructed from 2 points")
  }
  new_circle2(create_circle_2_2_point(get_ptr(p), get_ptr(q)))
}
new_circle_from_2_spheres <- function(s1, s2) {
  new_circle3(create_circle_3_sphere_sphere(get_ptr(s1), get_ptr(s2)))
}
new_circle_from_sphere_plane <- function(s, p) {
  new_circle3(create_circle_3_sphere_plane(get_ptr(s), get_ptr(p)))
}
