```sh
docker build -t moodle:${MOODLE_VERSION:-"latest"} --build-arg HTTP_PROXY=${HTTP_PROXY} .
```

