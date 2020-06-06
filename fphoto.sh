#!/bin/bash
#
# fphoto.sh - Organiza arquivos .jpg e .jpeg em subdiretórios no padrão YYYY/MM
# 
# Site      : https://github.com/francoisjun/shell-scripts
# Autor     : François Júnior <francoisjun84@gmail.com>
# 
# -----------------------------------------------------------------------------
#  Este programa busca todos os arquivos .jpg e .jpeg no diretório corrente e 
#  faz uma cópia desses arquivos em subdiretórios na pasta $HOME/Imagens (ou 
#  $HOME/Pictures, o que existir nessa ordem. Caso não existam, será criado o 
#  $HOME/Imagens) no pardão YYYY/MM (ano/mês) com base na data de modificação.
# -----------------------------------------------------------------------------
#
# Este programa usa o Versionamento Semântico 2.0.0
# https://semver.org/lang/pt-BR/spec/v2.0.0.html
#
# Histórico:
#
#   v1.0.0: 2020-06-06, François Júnior:
#       - Versão inicial
#
#
# Licença: MIT
#

MESSAGE="
Organiza arquivos .jpg e .jpeg em subdiretórios no padrão YYYY/MM

Uso: $(basename $0) [OPÇÕES]

OPÇÕES:
    -c      Troca os espaços do nome do arquivo por '_'
    -l      Muda o nome do arquivo para lowercase
    -u      Muda o nome do arquivo para UPPERCASE
    
    -m      Move os arquivos em vez de copiar
    -o DIR  Diretório onde deverão ser salva as imagens

    -h      Mostra essa tela de ajuda e sai
    -v      Mostra a versão do programa e sai
"

# ==[ FLAGS ]==================================================================
COMMAND="cp -p"        # Comando que irá atuar nos arquivos (cp ou mv)
LOWER=0                # Define se deve mudar o nome dos arquivos para lowercase
UPPER=0                # Define se deve mudar o nome dos arquivos para uppercase
CHSPACE=0              # Define se deve trocar espaços por "_"
OUTPUT="$HOME/Imagens" # Diretório de saída

#verifica se existe $HOME/Imagens. Caso não, troca por $HOME/Pictures
test -d $OUTPUT || (test -d "$HOME/Pictures" && OUTPUT="$HOME/Imagens")


# ==[ TRATAMENTO DAS OPÇÕES ]==================================================
while getopts ":hvlucmo:" opcao
do
    case "$opcao" in
        h)
            echo "$MESSAGE"
            exit 0
        ;;
        
        v)
            echo -n $(basename $0)
            #extrai a versão diretamente dos cabeçalhos do programa
            grep '^#   v' "$0" | tail -1 | cut -d : -f 1 | tr -d \#
            exit 0
        ;;

        o)  OUTPUT="$OPTARG" ;;
        m)  COMMAND="mv"     ;;
        l)  LOWER=1          ;;
        u)  UPPER=1          ;;
        c)  CHSPACE=1        ;;
        
        \?)
            echo Opção inválida: $1. 
            echo Use $(basename $0) -h para ajuda.
            exit 1
        ;;

        :)
            echo Faltou o argumento para: $OPTARG
            exit 1
        ;;
    esac
done


# ==[ EXECUÇÃO ]===============================================================
for arquivo in *.{jpg,jpeg,JPG,JPEG}
do
    if test "$arquivo" != "*.jpg"  && test "$arquivo" != "*.JPG"  && \
       test "$arquivo" != "*.jpeg" && test "$arquivo" != "*.JPEG"
    then
        subdir=$(stat -c "%y" "$arquivo" | \
                cut -d" " -f1 | \
                cut -d"-" -f -2 --output-delimiter="/")

        fulldir="$OUTPUT/$subdir"
        arquivonovo=$arquivo

        # conversões do nome do arquivo
        test $CHSPACE -eq 1 && arquivonovo=$(echo "$arquivonovo" | tr -s " " "_")
        test $LOWER   -eq 1 && arquivonovo=${arquivonovo,,}
        test $UPPER   -eq 1 && arquivonovo=${arquivonovo^^}
        
        test -d "$fulldir" || mkdir -p "$fulldir"
        $COMMAND "$arquivo" "$fulldir/$arquivonovo"        
    fi  
done