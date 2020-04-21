FROM golang:alpine as build-env

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories
RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories
RUN apk update
RUN apk add megatools

RUN apk --no-cache add gcc g++ make git
# RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# RUN apk update \
#     && apk add -u git

##RUN apk add --update git

# Add Maintainer Info
LABEL maintainer="Supratick Dey"

# Set the Current Working Directory inside the container
RUN mkdir /app
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source from the current directory to the Working Directory inside the container
COPY . .



# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -o /go/bin/godocker
##RUN chmod +x script.sh

# Run the bin
FROM scratch
COPY --from=build-env /go/bin/godocker /go/bin/godocker
ENTRYPOINT ["/go/bin/godocker"]