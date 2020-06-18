FROM trestletech/plumber

COPY [".", "./"]

ENTRYPOINT ["Rscript", "-e", "pr <- plumber::plumb(commandArgs()[4]); pr$run(host='0.0.0.0', port=as.numeric(Sys.getenv('PORT')), swagger = T)"]

CMD ["Plumber.R"]