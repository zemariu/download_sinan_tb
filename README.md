
<!-- README.md is generated from README.Rmd. Please edit that file -->

# download_sinan_tb

Autor: José Mário Nunes da Silva

e-mail: <zemariu@usp.br>

<!-- badges: start -->

<!-- badges: end -->

## A Função `download_sinan_tb()`

A função **`download_sinan_tb()`** foi criada para **automatizar o
download de bases do SINAN (Sistema de Informação de Agravos de
Notificação)** referentes à **tuberculose**, disponibilizadas em formato
`.dbc` pelo **DATASUS**.

Ela permite baixar dados de anos específicos ou de todos os anos
disponíveis, salvar os arquivos em uma pasta escolhida no seu computador
e, opcionalmente, forçar a atualização dos bancos já existentes.

## Como funciona:

- Após carregar o script com `source()`, a função passa a ficar
  disponível no ambiente do R.
- No **RStudio**, você pode confirmar sua presença observando o painel
  **Environment** (canto superior direito), onde o nome
  `download_sinan_tb` aparecerá listado.
- O argumento `directory` (ou `out_dir`) define **o local onde os
  arquivos serão salvos**. Recomenda-se utilizar uma pasta dedicada e
  organizada (ex.: `"BancosTB"`).

## Principais argumentos:

- **`anos`** → pode ser um ou mais anos (`2019:2023`) ou `"all"` para
  baixar todos os anos disponíveis.
- **`directory`** → caminho da pasta onde os arquivos `.dbc` serão
  salvos.
- **`overwrite`** (padrão = `FALSE`) → se `TRUE`, força o re-download
  mesmo que o arquivo já exista na pasta.

## Exemplos de uso

### Baixar anos específicos

``` r
# Baixa somente 2020 e 2021 
download_sinan_tb(anos = 2020:2021, 
                  directory = "BancosTB")
```

### Baixar todos os anos disponíveis

``` r
# Baixa todos os anos disponíveis no DATASUS
download_sinan_tb(anos = "all", 
                  directory = "BancosTB")
```

### Forçar atualização

``` r
# Rebaixa arquivos de 2019 a 2023 mesmo que já existam
download_sinan_tb(anos = 2019:2023, 
                  directory = "BancosTB", 
                  overwrite = TRUE)
```

## Observações

Os arquivos baixados são salvos em formato `.dbc`, padrão do DATASUS.
Para instalar o pacote use:

``` r
devtools::install_github("danicat/read.dbc")
```

ou, alternativamente:

``` r
install.packages("read.dbc", 
repos = "https://packagemanager.posit.co/cran/2024-07-05")
```

Maiores informações sobre o pacote estão disponíveis em:
<https://github.com/danicat/read.dbc>.

## Importando os arquivos

A leitura posterior pode ser feita com o pacote **`read.dbc`**. Exemplo:

``` r
library(read.dbc)
dadostb <- read.dbc("BancosTB/TUBEBR23.dbc")
```

Garanta que sua pasta de destino (`directory`) já exista ou crie-a antes
de rodar a função.
