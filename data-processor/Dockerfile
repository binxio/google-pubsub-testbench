# FROM 		golang:1.14
#
# WORKDIR		/data-processor
# ADD		. /data-processor
# RUN		CGO_ENABLED=0 GOOS=linux go build -ldflags '-extldflags "-static"' .
#
# FROM 		scratch
#
# ENV 		PORT=8080
# EXPOSE 		8080
# ENTRYPOINT 	["/data-processor"]
#
# COPY --from=0	/data-processor/data-processor /

FROM golang:1.14 AS builder
# Enable static compilation
ENV CGO_ENABLED 0
# Set the working directory for next instructions
WORKDIR /go/src/app
# Pull in all the local files
COPY . .
# Build the app
#TODO could use: -ldflags="-X 'package_path.variable_name=development'" ##### to find the path, use: go tool nm . | grep variable_name
#also: -ldflags '-extldflags "-static"' . ##### ?
RUN go build -o /go/bin/app
# # A new stage: reset the container image
FROM gcr.io/distroless/static:nonroot
# # Copy app from previous stage
COPY --from=builder /go/bin/app /go/bin/app
# # Set the default command to run when you start the container
ENTRYPOINT ["/go/bin/app"]
