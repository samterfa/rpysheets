FROM samterfa/rmlsheets

COPY [".", "./"]

ENTRYPOINT ["Rscript", "-e", "pr <- plumber::plumb(commandArgs()[9]); pr$run(host='0.0.0.0', port=as.numeric(Sys.getenv('PORT')), swagger = T)"]

CMD ["Plumber.R"]