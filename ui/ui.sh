#!/bin/sh

if [[ "${DEFAULT_PROMPT}" ]]; then
    find /app/.next -type f -name '*.js' -exec sed -i "s/You are ChatGPT, a large language model trained by OpenAI. Follow the user's instructions carefully. Respond using markdown./${DEFAULT_PROMPT}/g" {} \;
fi

if [[ "${DEFAULT_MODEL}" ]]; then
    find /app/.next -type f -name '*.js' -exec sed -i "s/gpt-3.5-turbo/\/models\/${DEFAULT_MODEL}/g" {} \;
    find /app/.next -type f -name '*.js' -exec sed -i "s/GPT-3.5/${DEFAULT_MODEL}/g" {} \;
fi

if [[ "${DEFAULT_TEMPERATURE}" ]]; then
    find /app/.next -type f -name '*.js' -exec sed -i "s/TEMPERATURE||\"1\"/TEMPERATURE||\"${DEFAULT_TEMPERATURE}\"/g" {} \;
fi

cd /app

exec npm start
