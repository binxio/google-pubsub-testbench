FROM 		golang:1.14

WORKDIR		/app
ADD		. /app
RUN		CGO_ENABLED=0 GOOS=linux go build -ldflags '-extldflags "-static"' .

FROM 		scratch

ENTRYPOINT 	["/app-forwarder"]

COPY --from=0	/app/app-forwarder /
