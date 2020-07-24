FROM 		golang:1.14

WORKDIR		/data-processor
ADD		. /data-processor
RUN		CGO_ENABLED=0 GOOS=linux go build -ldflags '-extldflags "-static"' .

FROM 		scratch

ENV 		PORT=8080
EXPOSE 		8080
ENTRYPOINT 	["/data-processor"]

COPY --from=0	/data-processor/data-processor /
