#'-------------------------------------------------------------------
#' Curso: Epidemiologia descritiva aplicada à tuberculose
#' Função para baixar dados SINAN-TUBERCULOSE (DATASUS)
#' Autor: José Mário Nunes da Silva Ph.d
#' Contato: zemariu@usp.br
#'-------------------------------------------------------------------
#' Exemplo:
#' Baixar todos os anos disponíveis
#' download_sinan_tb(anos = "all", directory = "~/CursoR/BancosTB")
#' Baixar só 2020 e 2021
#' sinan_tb(anos = 2020:2021, diretorio = "~/CursoR/BancosTB")
#' OBS: Para substituir arquivos já existentes, use overwrite = TRUE
#--------------------------------------------------------------------

download_sinan_tb <- function(
    anos,                       # ex.: 2010:2024 ou "all"
    directory = getwd(),        # pasta destino
    overwrite = FALSE,          # TRUE para substituir arquivos existentes
    quiet = FALSE               # suprimir mensagens
){
  stopifnot(length(anos) >= 1 || identical(anos, "all"))

  urls_base <- c(
    "ftp://ftp.datasus.gov.br/dissemin/publicos/SINAN/DADOS/FINAIS/",
    "ftp://ftp.datasus.gov.br/dissemin/publicos/SINAN/DADOS/PRELIM/"
  )

  listar_ftp <- function(url){
    if (requireNamespace("RCurl", quietly = TRUE)) {
      txt <- RCurl::getURL(url, ftp.use.epsv = FALSE, dirlistonly = TRUE)
      ent <- strsplit(txt, "\r*\n")[[1]]
      ent <- ent[nzchar(ent)]
      paste0(url, ent)
    } else {
      con <- url(url); on.exit(try(close(con), silent = TRUE), add = TRUE)
      ent <- try(readLines(con, warn = FALSE), silent = TRUE)
      if (inherits(ent, "try-error")) stop("Falha ao listar FTP.")
      ent <- ent[nzchar(ent)]
      paste0(url, ent)
    }
  }

  # extrator de ano (2 dígitos no final do nome)
  get_ano <- function(nome){
    m2 <- regmatches(nome, regexpr("\\d{2}(?=\\.dbc$)", nome, perl = TRUE))
    if (length(m2) && nzchar(m2)) {
      aa <- as.integer(m2)
      return(as.integer(if (aa <= 30) 2000 + aa else 1900 + aa))
    }
    m4 <- regmatches(nome, regexpr("(19|20)\\d{2}", nome))
    if (length(m4) && nzchar(m4)) return(as.integer(m4))
    return(NA_integer_)
  }

  if (!quiet) message("Listando FTP (FINAIS e PRELIM)...")
  lista <- unlist(lapply(urls_base, listar_ftp), use.names = FALSE)
  if (!length(lista)) stop("Nenhum arquivo encontrado.")

  lista <- lista[grepl("TUBEBR", lista, ignore.case = TRUE)]  # só tuberculose BR
  df <- data.frame(
    url  = lista,
    base = ifelse(grepl("/FINAIS/", lista), "FINAIS", "PRELIM"),
    file = basename(lista),
    stringsAsFactors = FALSE
  )

  df$ano <- vapply(df$file, get_ano, integer(1))

  if (!identical(anos, "all")) {
    df <- df[!is.na(df$ano) & df$ano %in% as.integer(anos), , drop = FALSE]
    if (!nrow(df)) stop("Nenhum arquivo corresponde aos anos informados.")
  }

  # priorizar FINAIS
  ord <- ifelse(df$base == "FINAIS", 1L, 2L)
  df <- df[order(df$file, ord), ]
  df <- df[!duplicated(df$file), ]

  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  df$dest <- file.path(out_dir, df$file)
  df$existe <- file.exists(df$dest)
  df$baixar <- if (overwrite) TRUE else !df$existe

  if (!quiet) {
    message("Arquivos candidatos: ", nrow(df))
    message("Precisam baixar:     ", sum(df$baixar))
  }

  if (any(df$baixar)) {
    idx <- which(df$baixar)
    for (k in seq_along(idx)) {
      i <- idx[k]
      if (!quiet) message(sprintf("Baixando [%d/%d] (%s): %s",
                                  k, length(idx), df$base[i], df$file[i]))
      utils::download.file(df$url[i], df$dest[i], mode = "wb", quiet = quiet)
    }
    if (!quiet) message("Concluído!")
  } else if (!quiet) {
    message("Nada a baixar (use overwrite=TRUE para substituir).")
  }

  invisible(df[, c("file","ano","base","url","dest","baixar","existe")])
}
