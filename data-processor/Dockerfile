FROM 		golang:1.14

WORKDIR		/app
ADD		. /app
RUN		CGO_ENABLED=0 GOOS=linux go build -ldflags '-extldflags "-static"' .

FROM 		scratch

ENV 		PORT=8080
EXPOSE 		8080
ENTRYPOINT 	["/data-processor"]

COPY --from=0	/app/app /
