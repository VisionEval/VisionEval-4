# Focused regression tests for complete-identity prediction alignment.

local({
  model_a <- stats::lm(y ~ x, data = data.frame(x = c(0, 1), y = c(10, 11)))
  model_b <- stats::lm(y ~ x, data = data.frame(x = c(0, 1), y = c(20, 21)))
  models <- tibble::tibble(
    Segment = c("A", "B"),
    model = list(model_a, model_b)
  )

  run_predictions <- function(ids, merge_preds = TRUE) {
    segment <- rep(c("A", "B"), length.out = length(ids))
    x <- seq_along(ids) - 1
    dataset <- data.frame(
      HhId = ids,
      Segment = segment,
      x = x,
      stringsAsFactors = FALSE
    )
    result <- VETravelDemandMM::DoPredictions(
      models, dataset, "household-alignment-test", "HhId", "y", "Segment",
      merge_preds = merge_preds
    )
    list(
      dataset = dataset,
      expected_y = ifelse(segment == "A", 10 + x, 20 + x),
      result = result
    )
  }

  expect_aligned <- function(ids) {
    test <- run_predictions(ids)
    stopifnot(
      identical(as.character(test$result$id), test$dataset$HhId),
      isTRUE(all.equal(as.numeric(test$result$y), test$expected_y))
    )
    invisible(test)
  }

  expect_error_message <- function(expression, text) {
    message <- tryCatch({
      force(expression)
      NA_character_
    }, error = conditionMessage)
    stopifnot(!is.na(message), grepl(text, message, fixed = TRUE))
  }

  # 1. Numeric Azones produce more than one numeric substring per identity.
  expect_aligned(c("51001-1", "51003-1", "51001-2", "51003-2"))

  # 2. Household suffixes repeat across nonnumeric Azones.
  nonnumeric <- expect_aligned(c(
    "Gloucester County-1", "Hampton-1",
    "Gloucester County-2", "Hampton-2"
  ))

  # 3. The single-Azone RVMPO identity shape retains its existing behavior.
  expect_aligned(c("RVMPO-1", "RVMPO-2", "RVMPO-3"))

  # 4. Disabling alignment retains the segment-grouped row and value order.
  unmerged <- run_predictions(nonnumeric$dataset$HhId, merge_preds = FALSE)
  grouped_order <- c(1, 3, 2, 4)
  stopifnot(
    identical(as.character(unmerged$result$id),
              unmerged$dataset$HhId[grouped_order]),
    isTRUE(all.equal(as.numeric(unmerged$result$y),
                     unmerged$expected_y[grouped_order]))
  )

  align_rows <- getFromNamespace(".alignPredictionRows", "VETravelDemandMM")
  dataset_ids <- c("Azone A-1", "Azone B-1", "Azone A-2")
  predictions <- data.frame(
    id = dataset_ids[c(2, 3, 1)],
    y = c(20, 30, 10),
    stringsAsFactors = FALSE
  )

  # 5. Missing prediction identities fail explicitly.
  expect_error_message(
    align_rows(predictions[-1, , drop = FALSE], dataset_ids),
    "Predictions are missing 1 complete household identities."
  )

  # 6. Unexpected prediction identities fail explicitly.
  expect_error_message(
    align_rows(rbind(predictions, data.frame(id = "Unexpected-1", y = 40)),
               dataset_ids),
    "Predictions contain 1 unexpected complete household identities."
  )

  # 7. Duplicate identities on either side cannot form a safe mapping.
  duplicate_predictions <- predictions
  duplicate_predictions$id[[2]] <- duplicate_predictions$id[[1]]
  expect_error_message(
    align_rows(duplicate_predictions, dataset_ids),
    "Prediction household identities are not one-to-one."
  )
  expect_error_message(
    align_rows(predictions, c(dataset_ids[1], dataset_ids[1], dataset_ids[3])),
    "Dataset household identities are not one-to-one."
  )

  message("DoPredictions complete-identity alignment tests passed.")
})
