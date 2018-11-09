#!/usr/bin/env python3

import oauth.oauth as oauth
import httplib2
import uuid
import sys
import getopt
import json
import os

from urllib.parse import urlencode


def api_request(site, uri, method, key, secret, consumer_key, body=None):
    resource_tok_string = ("oauth_token_secret=%s&oauth_token=%s" %
        (secret, key))
    resource_token = oauth.OAuthToken.from_string(resource_tok_string)
    consumer_token = oauth.OAuthConsumer(consumer_key, "")

    oauth_request = oauth.OAuthRequest.from_consumer_and_token(
        consumer_token, token=resource_token, http_url=site,
        parameters={'oauth_nonce': uuid.uuid4().hex})
    oauth_request.sign_request(
        oauth.OAuthSignatureMethod_PLAINTEXT(), consumer_token, resource_token)
    headers = oauth_request.to_header()
    url = "%s%s" % (site, uri)
    http = httplib2.Http()
    if body:
        body = urlencode(body)
        headers['Content-type'] = 'application/x-www-form-urlencoded'
    return http.request(url, method, body=body, headers=headers)


def usage():
    print("%s <-a api.key> <-m GET/POST/PUT/DELETE> <-b base MAAS URL>"
          " <-u /partial/url/?op=foo> <-j input json string>" %
          os.path.basename(__file__))
    print(" -c, --suppress-content: suppress content")
    print("-r, --suppress-response: suppress response")
    print("            -a,--apikey: MAAS supplied apikey file")
    print("       -b,--basemaasurl: MAAS URL"
          " (e.g. http://localhost:5240/MAAS)")
    print("               -u,--uri: API uri"
          " (e.g. /accounts/?op=list_authorisation_tokens)")
    print("            -m,--method: GET/PUT/POST/DELETE")
    print("        -j,--json-input: Post input in string JSON form")


def main(argv):
    show_content = True
    show_response = True
    apikey = ''
    method = ''
    uri = ''
    base = ''
    json_input = ''
    get_opt_long_args = [
        "apikeyfile=",
        "method=",
        "uri=",
        "basemaasurl=",
        "suppress-content",
        "suppress-response",
        "json-input="
    ]

    try:
        opts, args = getopt.getopt(argv, "hcra:b:j:m:u:", get_opt_long_args)
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt == '-h':
            usage()
            sys.exit(0)
        elif opt in ('-c', '--suppress-content'):
            show_content = False
        elif opt in ('-r', '--suppress-response'):
            show_response = False
        elif opt in ("-a", "--apikeyfile"):
            apikey = arg
        elif opt in ("-m", "--method"):
            method = arg
        elif opt in ("-u", "--uri"):
            uri = arg
        elif opt in ("-b", "--basemaasurl"):
            base = arg
        elif opt in ("-j", "--json-input"):
            json_input = arg

    if method == '' or base == '' or uri == '' or apikey == '':
        usage()
        sys.exit(3)

    with open(apikey) as keyf:
        (ckey, key, secret) = keyf.readline().rstrip().split(":")
        keyf.close()

    body = None
    if json_input != '':
        body = json.loads(json_input)

    (response, content) = api_request("%s/api/2.0" % base,
                                      uri, method, key, secret, ckey, body)

    if show_response:
        print(response)

    if show_content:
        print(content.decode('utf-8'))


if __name__ == "__main__":
    main(sys.argv[1:])
