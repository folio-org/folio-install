### For speedy FOLIO loans migration via the API, it is necessary to disable the timer interface for mod-circulation.

To do this:

1) Pull down the existing version of mod-circulation's module descriptor. This should be in your Okapi instance at ```http://okapi:9130/_/proxy/modules/mod-circulation-<#>.<#>.<#>```

2) Edit this module descriptor in a text editor, removing the section starting with:
```
{
    "id" : "_timer",
    ...
    ...
},
```
3) Give the "id" at the top of the module descriptor a high version number, so it doesn't overwrite any existing mod-circulation module descriptor ids.

Save this as *md.json*

4) Create a deployment descriptor json file that looks something like this:
```
{
  "instId" : "mod-circulation-99.1.1",
  "srvcId" : "mod-circulation-99.1.1",
  "url" : "http://mod-circulation-notimers:9801"
}
```
Save this as *dd.json*

5) Create a tenant enable json file that looks something like this:
```
[
  {
    "id": "mod-circulation-99.1.1",
    "action": "enable"
  }
]
```
Save this as *et.json*

6. Deploy the existing module version tag in Rancher/K8s, exposing port 9801, but name the Workload and service this:

*mod-circulation-notimers*

7) Curl in the above files to your Okapi instance. First to */_/proxy/modules*, next to */_/discovery/modules* and finally enable for the tenant of your choice. Example commands below:

```
curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @md.json http://okapi:9130/_/proxy/modules

curl -i -w '\n' -X POST -H 'Content-type: application/json' \
-d @dd.json http://okapi:9130/_/discovery/modules

curl -w '\n' -D - -X POST -H "Content-type: application/json" \
-d @et.json \
http://okapi:9130/_/proxy/tenants/tamu/install?deploy=false\&preRelease=false\&tenantParameters=loadSample%3Dfalse%2CloadReference%3Dfalse
```
8) When your loans migration has completed, re-enable the original mod-circulation module version for your tenant. To do this, edit the *et.json* from before, changing back the version there. That looks something like this:
```
[
  {
    "id": "mod-circulation-22.0.7",
    "action": "enable"
  }
]
```

9) Curl in the above to your Okapi instance, example command below:

```
curl -w '\n' -D - -X POST -H "Content-type: application/json" \
-d @et.json \
http://okapi:9130/_/proxy/tenants/tamu/install?deploy=false\&preRelease=false\&tenantParameters=loadSample%3Dfalse%2CloadReference%3Dfalse
```
