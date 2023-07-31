FROM golang AS builder

RUN git clone https://github.com/Fantom-foundation/go-opera.git

ENV CGO_ENABLED=1
ENV GOOS=linux
ENV GOARCH=amd64

RUN cd go-opera  
RUN cd go-opera && go build \
	    -ldflags "-s -w -extldflags '-static' -X github.com/Fantom-foundation/go-opera/cmd/opera/launcher.gitCommit=$${GIT_COMMIT} -X github.com/Fantom-foundation/go-opera/cmd/opera/launcher.gitDate=$${GIT_DATE}" \
	    -o build/opera \
	    ./cmd/opera && \
          cp build/opera /usr/local/bin

RUN useradd -m opera
USER opera
WORKDIR /home/opera
RUN mkdir -p /home/opera/.opera

FROM scratch AS final

COPY --from=builder /usr/local/bin/opera /usr/local/bin/opera
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /home/opera /home/opera
USER opera

WORKDIR /home/opera
ENTRYPOINT [ "/usr/local/bin/opera" ]
CMD ["--fakenet", "0/4", "--db.preset", "pbl-1", \
 "--bootnodes", "enode://2d232bb62e95dcbe9056b13e847285e8a29cfc7ec7ddbef5dcae050d54b42e17cd8a7c5d05d11e0bb1df4ab0129f4b42d979073ed4396f393cd47addb3e2ccb9@54.219.181.6:5050,enode://70b4b0baa8c75acc986c2dfcf3b1450cd94dc90a9f84dfc9888c54324bc57c9cd7466551057edc9d86c763593ba638cdda644bd454854804f36d5dce799ca3cc@54.241.209.227:5050,enode://d5b49249df049c171e6c4d837ec320f8b58657a2dbba3b16cf2ca7d108ad3bc2b03a45882c5df492e4c836b7271a3f48e4d4596d44ac2e69495bb4facd7e8821@54.176.89.121:5050,enode://4cb4b4d882bf0d50c27b2def8694160c2e273dc012ccbc9d5eed5e55dd2561c2be41a62bd27cc0b78d38b5812b90099083b0c2af76e7495110e13e2deb72e772@52.8.54.200:5050" ]
