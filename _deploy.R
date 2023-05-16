# Verify environmental variables

cli::cli_h3("Verifying Enviromental Variables")

verify_env <- function(name) {
    value <- Sys.getenv(name)
    if (value == "") {
        cli::cli_inform(c("x" = "{name}"))
    } else {
        cli::cli_inform(c("v" = "{name}"))
    }
}


c(
    "DB_HOST",
    "DB_USER",
    "DB_SECRET",
    "DB_NAME",
    "DB_PORT",
    "GITHUB_PAT",
    "FIREBASE_API_KEY",
    "FIREBASE_PROJECT_ID",
    "FIREBASE_AUTH_DOMAIN",
    "FIREBASE_STORAGE_BUCKET",
    "FIREBASE_APP_ID",
    "OPENAI_API_KEY",
    "REPORTES_EMAIL",
    "REPORTES_API_TEST_ORG"
) |>
    purrr::walk(verify_env)


# Get latest github release ----

cli::cli_h3("Getting latest GH release")

releases <- gh::gh("/repos/calderonsamuel/appReporteAvance/releases")

tags <- purrr::map_chr(releases, "tag_name")
created_at <- purrr::map_vec(releases, ~lubridate::as_datetime(.x$created_at))

latest_gh_release <- data.frame(tags, created_at) |> 
    subset(created_at == max(created_at)) |> 
    purrr::pluck("tags")

cli::cli_inform("Lates github release is {latest_gh_release}")

remote_to_install <- glue::glue("calderonsamuel/appReporteAvance@{latest_gh_release}")

# Install and update ----

cli::cli_h3("Installing latest GH release")
pak::pkg_install(remote_to_install, ask = FALSE)

cli::cli_h3("Updating rev.lock")
renv::snapshot(prompt = FALSE)

cli::cli_h3("Starting deploy")
rsconnect::deployApp(account = "samuelcalderon01", appName = "reportes", forceUpdate = TRUE)
