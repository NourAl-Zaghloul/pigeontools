#' Cleans raw data to be ready for processing
#'
#' @param x List of raw data
#' @param method Type of raw data being clean
#' @return A dataframe with usable, organised, and standardized but not processed data.
#' @example
#' pigeon_clean(mydata1, "datavyu")
pigeon_clean <- function(x, method = "default"){
  if (method == "habit") {

    for(i in seq(x)) {

      x[[i]]$Trial <- as.integer(x[[i]]$Trial)
      x[[i]]$Repeat <- as.integer(x[[i]]$Repeat)
      x[[i]]$StimID <- as.integer(x[[i]]$StimID)
      x[[i]]$'Trial Start' <- as.integer(x[[i]]$'Trial Start')
      x[[i]]$'Trial End' <- as.integer(x[[i]]$'Trial End')
      x[[i]]$TotalLook <- as.integer(x[[i]]$TotalLook)
      x[[i]]$TotalLookAway <- as.integer(x[[i]]$TotalLookAway)
      x[[i]]$TotalLeft <- as.integer(x[[i]]$TotalLeft)
      x[[i]]$TotalCenter <- as.integer(x[[i]]$TotalCenter)
      x[[i]]$TotalRight <- as.integer(x[[i]]$TotalRight)
      x[[i]]$LookEnabled <- as.integer(x[[i]]$LookEnabled)
      x[[i]]$LookDisabled <- as.integer(x[[i]]$LookDisabled)

      x[[i]]$Trial <- seq(1,nrow(x[[i]]))

    }

    OUT <- do.call(rbind, x)
    invisible(return(OUT))

  } else if (method == "director"){

    files <- names(x)
    naming <- unlist(strsplit(files, "10", fixed = 2))
    numbers <- naming[c(FALSE, TRUE)]
    study <- naming[c(TRUE, FALSE)]

    for(i in seq(x)) {

      srow <- grep(":", x[[i]][, 1])
      x_temp <- x[[i]][(srow[2] + 1):nrow(x[[i]]), ]
      colnames(x_temp) <- c("trial_info", "order", "side_info")

      colnames(x[[i]]) <- x[[i]][srow[1] + 1, ]
      x[[i]] <- x[[i]][(srow[1] + 2):(srow[2] - 1), ]
      cbind(x[[i]], x_temp)

      x[[i]] <- x[[i]][complete.cases(x[[i]][, 1]), ]

      x[[i]]$Code <- rep(files[[i]], length(x[[i]]$Code))
      x[[i]]$study <- rep(files[[i]], length(x[[i]]$Sub))
      x[[i]]$part <- rep(numbers[[i]], length(x[[i]]$Sub))
      x[[i]] <- x[[i]][ , -c("Sub")]

      x[[i]]$Sub <- as.integer(x[[i]]$Sub)
      x[[i]]$AgeMos <- as.integer(x[[i]]$AgeMos)
      x[[i]]$trial <- as.integer(x[[i]]$trial)
    }

    OUT <- do.call(rbind, x)
    invisible(return(OUT))

  } else if (method == "datavyu"){

    for (i in seq(x)){
      fourth <- seq(4,ncol(x[[i]]),4)
      trialnames <- colnames(x[[i]])
      trialnames[fourth] <- sub('\\..*', '\\.code01', names(x[[i]][fourth]))
      names(x[[i]]) <- trialnames

      if (is.na(x[[i]]$coder1.onset[1])){
        next()
      }

      trial <- rep(0,length(x[[i]]$coder1.onset[!is.na(x[[i]]$coder1.onset)]))
      ttrial <- x[[i]]$trial.onset[!is.na(x[[i]]$trial.onset)]

      for(t in 1:length(trial)){
        for(tt in 1:length(ttrial)){
          if(x[[i]]$coder1.onset[t] == ttrial[tt]){
            trial[t] <- tt
          } else {
            next()
          }
        }
      }

      x_subset <- as.list(rep("",length(trial)))

      for(j in 1:length(na.omit(x_subset))){

        x_subset[[j]] <- data.frame(na.omit(subset(x[[i]],x[[i]]$look_1.onset >= x[[i]]$trial.onset[j] &
                                                     x[[i]]$look_1.onset <= x[[i]]$trial.offset[j],
                                                   select = c(look_1.onset, look_1.offset, look_1.code01))))

        x_subset[[j]] <- dplyr::mutate(x_subset[[j]], look_1.duration = look_1.offset - look_1.onset)

        x_subset[[j]]$trial <- rep(trial[j], length(x_subset[[j]]$look_1.duration))

        x_subset[[j]]$coder1.code01 <- rep(x[[i]]$coder1.code01[j], length(x_subset[[j]]$look_1.duration))

        x_subset[[j]]$part <- rep(x[[i]]$participant.code01[1], length(x_subset[[j]]$look_1.duration))

      }

      x[[i]] <- do.call(rbind, x_subset)

    }

    OUT <- do.call(rbind, x)
    invisible(return(OUT))

  } else if (method == "datavyu2") {
    print("This section hasn't been created yet")

  } else if (method == "default") {
    print("You need to choose a method")
  }

}
