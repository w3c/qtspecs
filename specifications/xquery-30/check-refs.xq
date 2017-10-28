declare function local:unused($file as xs:string)
{
    for $error in doc($file)//error
    let $refs := doc($file)//errorref
    where empty($refs[@code=$error/@code and not(./ancestor::*[@diff="del"])])
    order by $error/@code
    return <unused code="{$error/@code}" />
};

declare function local:undefined($file as xs:string)
{
    for $ref in doc($file)//errorref
    let $errors := doc($file)//error
    where not($ref/ancestor::*[@diff="del"])
      and empty($errors[@code=$ref/@code])
    order by $ref/@code
    return <undefined code="{$ref/@code}" />
};

<linkcheck>
 <unused-errors>
   <xquery-30>{ local:unused("html/xquery-30.xml") }</xquery-30>
   <xpath-30>{ local:unused("html/xpath-30.xml") }</xpath-30>
   <shared-30>{ local:unused("html/shared-30.xml") }</shared-30>
 </unused-errors>
 <dangling-refs>
   <xquery-30>{ local:undefined("html/xquery-30.xml") }</xquery-30>
   <xpath-30>{ local:undefined("html/xpath-30.xml") }</xpath-30>
   <shared-30>{ local:undefined("html/shared-30.xml") }</shared-30>
 </dangling-refs>
</linkcheck>
