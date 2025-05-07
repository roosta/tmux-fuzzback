FROM alpine:latest

WORKDIR /app
COPY . ./
COPY ./tests/tmux.conf /etc

RUN apk update && apk add --no-cache bash fzf fzf-tmux vim tmux expect

ENV TERM="tmux-256color"
CMD ["bash"]
CMD ["/app/tests/test_fuzzback.sh"]
