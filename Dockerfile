FROM alpine:3.11.6

COPY scripts/entrypoint.sh /usr/local/bin/

ENTRYPOINT ["entrypoint.sh"]

CMD ["info"]
