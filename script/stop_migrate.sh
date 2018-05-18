#!/bin/bash

kill -9 `ps aux | grep migrate_ | awk '{print $2}'`
