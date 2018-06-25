#!/bin/bash

kill -9 `ps aux | grep rm_ | awk '{print $2}'`
