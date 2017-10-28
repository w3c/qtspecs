(: parse tests :)
<bib>
 {
  for $b in doc("http://bstore1.example.com/bib.xml")/bib/book
  where $b/publisher = "Addison-Wesley" and $b/@year > 1991
  return
    <book year="{ $b/@year }">
     { $b/title }
    </book>
 }
</bib> 
%%%<results>
  {
    for $b in doc("http://bstore1.example.com/bib.xml")/bib/book,
        $t in $b/title,
        $a in $b/author
    return
        <result>
            { $t }    
            { $a }
        </result>
  }
</results>
                        
%%%<results>
{
    for $b in doc("http://bstore1.example.com/bib.xml")/bib/book
    return
        <result>
            { $b/title }
            { $b/author  }
        </result>
}
</results> 
%%%<results>
  {
    let $a := doc("http://bstore1.example.com/bib/bib.xml")//author
    for $last in distinct-values($a/last),
        $first in distinct-values($a[last=$last]/first)
    order by $last, $first
    return
        <result>
            <author>
               <last>{ $last }</last>
               <first>{ $first }</first>
            </author>
            {
                for $b in doc("http://bstore1.example.com/bib.xml")/bib/book
                where some $ba in $b/author 
                      satisfies ($ba/last = $last and $ba/first=$first)
                return $b/title
            }
        </result>
  }
</results> 
%%%<books-with-prices>
  {
    for $b in doc("http://bstore1.example.com/bib.xml")//book,
        $a in doc("http://bstore2.example.com/reviews.xml")//entry
    where $b/title = $a/title
    return
        <book-with-prices>
            { $b/title }
            <price-bstore2>{ $a/price/text() }</price-bstore2>
            <price-bstore1>{ $b/price/text() }</price-bstore1>
        </book-with-prices>
  }
</books-with-prices>
%%%<bib>
  {
    for $b in doc("http://bstore1.example.com/bib.xml")//book
    where count($b/author) > 0
    return
        <book>
            { $b/title }
            {
                for $a in $b/author[position()<=2]  
                return $a
            }
            {
                if (count($b/author) > 2)
                 then <et-al/>
                 else ()
            }
        </book>
  }
</bib>
%%%<bib>
  {
    for $b in doc("http://bstore1.example.com/bib.xml")//book
    where $b/publisher = "Addison-Wesley" and $b/@year > 1991
    order by $b/title
    return
        <book>
            { $b/@year }
            { $b/title }
        </book>
  }
</bib> 
%%%for $b in doc("http://bstore1.example.com/bib.xml")//book
let $e := $b/*[contains(string(.), "Suciu") 
               and ends-with(local-name(.), "or")]
where exists($e)
return
    <book>
        { $b/title }
        { $e }
    </book> 
%%%<results>
  {
    for $t in doc("books.xml")//(chapter | section)/title
    where contains($t/text(), "XML")
    return $t
  }
</results> 
%%%<results>
  {
    let $doc := doc("prices.xml")
    for $t in distinct-values($doc//book/title)
    let $p := $doc//book[title = $t]/price
    return
      <minprice title="{ $t }">
        <price>{ min($p) }</price>
      </minprice>
  }
</results> 
%%%<bib>
{
        for $b in doc("http://bstore1.example.com/bib.xml")//book[author]
        return
            <book>
                { $b/title }
                { $b/author }
            </book>
}
{
        for $b in doc("http://bstore1.example.com/bib.xml")//book[editor]
        return
          <reference>
            { $b/title }
            {$b/editor/affiliation}
          </reference>
}
</bib>  
%%%<bib>
{
    for $book1 in doc("http://bstore1.example.com/bib.xml")//book,
        $book2 in doc("http://bstore1.example.com/bib.xml")//book
    let $aut1 := for $a in $book1/author 
                 order by $a/last, $a/first
                 return $a
    let $aut2 := for $a in $book2/author 
                 order by $a/last, $a/first
                 return $a
    where $book1 << $book2
    and not($book1/title = $book2/title)
    and deep-equal($aut1, $aut2) 
    return
        <book-pair>
            { $book1/title }
            { $book2/title }
        </book-pair>
}
</bib> 
%%%declare function local:toc($book-or-section as element()) as element()*
{
    for $section in $book-or-section/section
    return
      <section>
         { $section/@* , $section/title , local:toc($section) }			
      </section>
};

<toc>
   {
     for $s in doc("book.xml")/book return local:toc($s)
   }
</toc> 
%%%<figlist>
  {
    for $f in doc("book.xml")//figure
    return
        <figure>
            { $f/@* }
            { $f/title }
        </figure>
  }
</figlist> 
%%%<section_count>{ count(doc("book.xml")//section) }</section_count>, 
<figure_count>{ count(doc("book.xml")//figure) }</figure_count> 
%%%<top_section_count>
 { 
   count(doc("book.xml")/book/section) 
 }
</top_section_count>
%%%<section_list>
  {
    for $s in doc("book.xml")//section
    let $f := $s/figure
    return
        <section title="{ $s/title/text() }" figcount="{ count($f) }"/>
  }
</section_list> 
%%%declare function local:section-summary($book-or-section as element()*)
  as element()*
{
  for $section in $book-or-section
  return
    <section>
       { $section/@* }
       { $section/title }	
       <figcount>		
         { count($section/figure) }
       </figcount>		
       { local:section-summary($section/section) }			
    </section>
};

<toc>
  {
    for $s in doc("book.xml")/book/section
    return local:section-summary($s)
  }
</toc> 
%%%for $s in doc("report1.xml")//section[section.title = "Procedure"]
return ($s//incision)[2]/instrument
%%%for $s in doc("report1.xml")//section[section.title = "Procedure"]
return ($s//instrument)[position()<=2]
%%%let $i2 := (doc("report1.xml")//incision)[2]
for $a in (doc("report1.xml")//action)[. >> $i2][position()<=2]
return $a//instrument 
%%%for $p in doc("report1.xml")//section[section.title = "Procedure"]
where not(some $a in $p//anesthesia satisfies
        $a << ($p//incision)[1] )
return $p 
%%%declare function local:precedes($a as node(), $b as node()) as xs:boolean 
{
    $a << $b
      and
    empty($a//node() intersect $b)
};


declare function local:follows($a as node(), $b as node()) as xs:boolean 
{
    $a >> $b
      and
    empty($b//node() intersect $a)
};

<critical_sequence>
 {
  let $proc := doc("report1.xml")//section[section.title="Procedure"][1]
  for $n in $proc//node()
  where local:follows($n, ($proc//incision)[1])
    and local:precedes($n, ($proc//incision)[2])
  return $n
 }
</critical_sequence> 
%%%<critical_sequence>
 {
  let $proc := doc("report1.xml")//section[section.title="Procedure"][1],
      $i1 :=  ($proc//incision)[1],
      $i2 :=  ($proc//incision)[2]
  for $n in $proc//node() except $i1//node()
  where $n >> $i1 and $n << $i2
  return $n 
 }
</critical_sequence> 
%%%$c except $c//node()
%%%
declare function local:between($seq as node()*, $start as node(), $end as node())
 as item()*
{
  let $nodes :=
    for $n in $seq except $start//node()
    where $n >> $start and $n << $end
    return $n
  return $nodes except $nodes//node()
};

<critical_sequence>
 {
  let $proc := doc("report1.xml")//section[section.title="Procedure"][1],
      $first :=  ($proc//incision)[1],
      $second:=  ($proc//incision)[2]
  return local:between($proc//node(), $first, $second)
 }
</critical_sequence>
                        
%%%<result>
  {
    for $i in doc("items.xml")//item_tuple
    where $i/start_date <= current-date()
      and $i/end_date >= current-date() 
      and contains($i/description, "Bicycle")
    order by $i/itemno
    return
        <item_tuple>
            { $i/itemno }
            { $i/description }
        </item_tuple>
  }
</result>
%%%<result>
  {
    for $i in doc("items.xml")//item_tuple
    let $b := doc("bids.xml")//bid_tuple[itemno = $i/itemno]
    where contains($i/description, "Bicycle")
    order by $i/itemno
    return
        <item_tuple>
            { $i/itemno }
            { $i/description }
            <high_bid>{ max($b/bid) }</high_bid>
        </item_tuple>
  }
</result> 
%%%<result>
  {
    for $u in doc("users.xml")//user_tuple
    for $i in doc("items.xml")//item_tuple
    where $u/rating > "C" 
       and $i/reserve_price > 1000 
       and $i/offered_by = $u/userid
    return
        <warning>
            { $u/name }
            { $u/rating }
            { $i/description }
            { $i/reserve_price }
        </warning>
  }
</result>
%%%<result>
  {
    for $i in doc("items.xml")//item_tuple
    where empty(doc("bids.xml")//bid_tuple[itemno = $i/itemno])
    return
        <no_bid_item>
            { $i/itemno }
            { $i/description }
        </no_bid_item>
  }
</result> 
%%%<result>
  {
    for $seller in doc("users.xml")//user_tuple,
        $buyer in  doc("users.xml")//user_tuple,
        $item in  doc("items.xml")//item_tuple,
        $highbid in  doc("bids.xml")//bid_tuple
    where $seller/name = "Tom Jones"
      and $seller/userid  = $item/offered_by
      and contains($item/description , "Bicycle")
      and $item/itemno  = $highbid/itemno
      and $highbid/userid  = $buyer/userid
      and $highbid/bid = max(
                              doc("bids.xml")//bid_tuple
                                [itemno = $item/itemno]/bid
                         )
    order by ($item/itemno)
    return
        <jones_bike>
            { $item/itemno }
            { $item/description }
            <high_bid>{ $highbid/bid }</high_bid>
            <high_bidder>{ $buyer/name }</high_bidder>
        </jones_bike>
  }
</result> 
%%%<result>
  {
   unordered (
    for $seller in doc("users.xml")//user_tuple,
        $buyer in doc("users.xml")//user_tuple,
        $item in doc("items.xml")//item_tuple,
        $highbid in  doc("bids.xml")//bid_tuple
    where $seller/name = "Tom Jones"
      and $seller/userid  = $item/offered_by
      and contains($item/description , "Bicycle")
      and $item/itemno  = $highbid/itemno
      and $highbid/userid  = $buyer/userid
      and $highbid/bid = max(
                              doc("bids.xml")//bid_tuple
                                [itemno = $item/itemno]/bid
                         )
    return
        <jones_bike>
            { $item/itemno }
            { $item/description }
            <high_bid>{ $highbid/bid }</high_bid>
            <high_bidder>{ $buyer/name }</high_bidder>
        </jones_bike>
    )
  }
</result> 
%%%<result>
  {
    for $item in doc("items.xml")//item_tuple
    let $b := doc("bids.xml")//bid_tuple[itemno = $item/itemno]
    let $z := max($b/bid)
    where $item/reserve_price * 2 < $z
    return
        <successful_item>
            { $item/itemno }
            { $item/description }
            { $item/reserve_price }
            <high_bid>{$z }</high_bid>
         </successful_item>
  }
</result> 
%%%let $allbikes := doc("items.xml")//item_tuple
                    [contains(description, "Bicycle") 
                     or contains(description, "Tricycle")]
let $bikebids := doc("bids.xml")//bid_tuple[itemno = $allbikes/itemno]
return
    <high_bid>
      { 
        max($bikebids/bid) 
      }
    </high_bid> 
%%%let $item := doc("items.xml")//item_tuple
  [end_date >= xs:date("1999-03-01") and end_date <= xs:date("1999-03-31")]
return
    <item_count>
      { 
        count($item) 
      }
    </item_count>
%%%<result>
  {
    let $end_dates := doc("items.xml")//item_tuple/end_date
    for $m in distinct-values(for $e in $end_dates 
                              return month-from-date($e))
    let $item := doc("items.xml")
        //item_tuple[year-from-date(end_date) = 1999 
                     and month-from-date(end_date) = $m]
    order by $m
    return
        <monthly_result>
            <month>{ $m }</month>
            <item_count>{ count($item) }</item_count>
        </monthly_result>
  }
</result>
%%%<result>
 {
    for $highbid in doc("bids.xml")//bid_tuple,
        $user in doc("users.xml")//user_tuple
    where $user/userid = $highbid/userid 
      and $highbid/bid = max(doc("bids.xml")//bid_tuple[itemno=$highbid/itemno]/bid)
    order by $highbid/itemno
    return
        <high_bid>
            { $highbid/itemno }
            { $highbid/bid }
            <bidder>{ $user/name/text() }</bidder>
        </high_bid>
  }
</result> 
%%%let $highbid := max(doc("bids.xml")//bid_tuple/bid)
return
    <result>
     {
        for $item in doc("items.xml")//item_tuple,
            $b in doc("bids.xml")//bid_tuple[itemno = $item/itemno]
        where $b/bid = $highbid
        return
            <expensive_item>
                { $item/itemno }
                { $item/description }
                <high_bid>{ $highbid }</high_bid>
            </expensive_item>
     }
    </result> 
%%%declare function local:bid_summary()
  as element()*
{
    for $i in distinct-values(doc("bids.xml")//itemno)
    let $b := doc("bids.xml")//bid_tuple[itemno = $i]
    return
        <bid_count>
            <itemno>{ $i }</itemno>
            <nbids>{ count($b) }</nbids>
        </bid_count>
};

<result>
 {
    let $bid_counts := local:bid_summary(),
        $maxbids := max($bid_counts/nbids),
        $maxitemnos := $bid_counts[nbids = $maxbids]
    for $item in doc("items.xml")//item_tuple,
        $bc in $bid_counts
    where $bc/nbids =  $maxbids and $item/itemno = $bc/itemno
    return
        <popular_item>
            { $item/itemno }
            { $item/description }
            <bid_count>{ $bc/nbids/text() }</bid_count>
        </popular_item>
 }
</result> 
%%%<result>
 {
    for $uid in distinct-values(doc("bids.xml")//userid),
        $u in doc("users.xml")//user_tuple[userid = $uid]
    let $b := doc("bids.xml")//bid_tuple[userid = $uid]
    order by $u/userid
    return
        <bidder>
            { $u/userid }
            { $u/name }
            <bidcount>{ count($b) }</bidcount>
            <avgbid>{ avg($b/bid) }</avgbid>
        </bidder>
  }
</result> 
%%%<result>
 {
    for $i in distinct-values(doc("bids.xml")//itemno)
    let $b := doc("bids.xml")//bid_tuple[itemno = $i]
    let $avgbid := avg($b/bid)
    where count($b) >= 3
    order by $avgbid descending
    return
        <popular_item>
            <itemno>{ $i }</itemno>
            <avgbid>{ $avgbid }</avgbid>
        </popular_item>
  }
</result> 
%%%<result>
  {
    for $u in doc("users.xml")//user_tuple
    let $b := doc("bids.xml")//bid_tuple[userid=$u/userid and bid>=100]
    where count($b) > 1
    return
        <big_spender>{ $u/name/text() }</big_spender>
  }
</result>
                        
%%%<result>
  {
    for $u in doc("users.xml")//user_tuple
    let $b := doc("bids.xml")//bid_tuple[userid = $u/userid]
    order by $u/userid
    return
        <user>
            { $u/userid }
            { $u/name }
            {
                if (empty($b))
                  then <status>inactive</status>
                  else <status>active</status>
            }
        </user>
  }
</result>
                        
%%%<frequent_bidder>
  {
    for $u in doc("users.xml")//user_tuple
    where 
      every $item in doc("items.xml")//item_tuple satisfies 
        some $b in doc("bids.xml")//bid_tuple satisfies 
          ($item/itemno = $b/itemno and $u/userid = $b/userid)
    return
        $u/name
  }
</frequent_bidder>
%%%<result>
  {
    for $u in doc("users.xml")//user_tuple
    order by $u/name
    return
        <user>
            { $u/name }
            {
                for $b in distinct-values(doc("bids.xml")//bid_tuple
                                             [userid = $u/userid]/itemno)
                for $i in doc("items.xml")//item_tuple[itemno = $b]
                let $descr := $i/description/text()
                order by $descr
                return
                    <bid_on_item>{ $descr }</bid_on_item>
            }
        </user>
  }
</result>
                        
%%%<result>
  { 
    doc("sgml.xml")//report//para 
  }
</result>
%%%<result>
  { 
    doc("sgml.xml")//intro/para 
  }
</result>
%%%<result>
  {
    for $c in doc("sgml.xml")//chapter
    where empty($c/intro)
    return $c/section/intro/para
  }
</result> 
%%%<result>
  {
    (((doc("sgml.xml")//chapter)[2]//section)[3]//para)[2]
  }
</result> 
%%%<result>
  {
    doc("sgml.xml")//para[@security = "c"]
  }
</result> 
%%%<result>
  {
    for $s in doc("sgml.xml")//section/@shorttitle
    return <stitle>{ $s }</stitle>
  }
</result> 
%%%<result>
  {
    for $i in doc("sgml.xml")//intro/para[1]
    return
        <first_letter>{ substring(string($i), 1, 1) }</first_letter>
  }
</result> 
%%%<result>
   {
     doc("sgml.xml")//section[.//title[contains(., "is SGML")]]
   }
</result> 
%%%<result>
   {
     doc("sgml.xml")//section[.//title/text()[contains(., "is SGML")]]
   }
</result> 
%%%<result>
  {
    for $id in doc("sgml.xml")//xref/@xrefid
    return doc("sgml.xml")//topic[@topicid = $id]
  }
</result> 
%%%<result>
  {
    let $x := doc("sgml.xml")//xref[@xrefid = "top4"],
        $t := doc("sgml.xml")//title[. << $x]
    return $t[last()]
  }
</result> 
%%%doc("string.xml")//news_item/title[contains(., "Foobar Corporation")] 
%%%declare function local:partners($company as xs:string) as element()*
{
    let $c := doc("company-data.xml")//company[name = $company]
    return $c//partner
};

let $foobar_partners := local:partners("Foobar Corporation")

for $item in doc("string.xml")//news_item
where
  some $t in $item//title satisfies
    (contains($t/text(), "Foobar Corporation")
    and (some $partner in $foobar_partners satisfies
      contains($t/text(), $partner/text())))
  or (some $par in $item//par satisfies
   (contains(string($par), "Foobar Corporation")
     and (some $partner in $foobar_partners satisfies
        contains(string($par), $partner/text())))) 
return
    <news_item>
        { $item/title }
        { $item/date }
    </news_item> 
%%%declare function local:partners($company as xs:string) as element()*
{
    let $c := doc("company-data.xml")//company[name = $company]
    return $c//partner
};

for $item in doc("string.xml")//news_item,
    $c in doc("company-data.xml")//company
let $partners := local:partners($c/name)
where contains(string($item), $c/name)
  and (some $p in $partners satisfies
    contains(string($item), $p) and $item/news_agent != $c/name)
return
    $item 
%%%for $item in doc("string.xml")//news_item
where contains(string($item/content), "Gorilla Corporation")
return
    <item_summary>
        { concat($item/title,". ") }
        { concat($item/date,". ") }
        { string(($item//par)[1]) }
    </item_summary> 
%%%<Q1>
  {
    for $n in distinct-values(
                  for $i in (doc("auction.xml")//* | doc("auction.xml")//@*)
                  return namespace-uri($i) 
               )
    return  <ns>{$n}</ns>
  }
</Q1> 
%%%declare namespace music = "http://www.example.org/music/records";

<Q2>
  {
    doc("auction.xml")//music:title
  }
</Q2> 
%%%declare namespace dt = "http://www.w3.org/2001/XMLSchema";

<Q3>
  {
    doc("auction.xml")//*[@dt:*]
  }
</Q3> 
%%%declare namespace xlink = "http://www.w3.org/1999/xlink";

<Q4 xmlns:xlink="http://www.w3.org/1999/xlink">
  {
    for $hr in doc("auction.xml")//@xlink:href
    return <ns>{ $hr }</ns>
  }
</Q4>
%%%declare namespace music = "http://www.example.org/music/records";

<Q5 xmlns:music="http://www.example.org/music/records">
  {
     doc("auction.xml")//music:record[music:remark/@xml:lang = "de"]
  }
</Q5> 
%%%declare namespace ma = "http://www.example.com/AuctionWatch";
declare namespace anyzone = "http://www.example.com/auctioneers#anyzone";

<Q6 xmlns:ma="http://www.example.com/AuctionWatch">
  {
    doc("auction.xml")//ma:Auction[@anyzone:ID]/ma:Schedule/ma:Close
  }
</Q6>
%%%declare namespace ma = "http://www.example.com/AuctionWatch";

<Q7 xmlns:xlink="http://www.w3.org/1999/xlink">
  {
    for $a in doc("auction.xml")//ma:Auction
    let $seller_id := $a/ma:Trading_Partners/ma:Seller/*:ID,
        $buyer_id := $a/ma:Trading_Partners/ma:High_Bidder/*:ID
    where namespace-uri($seller_id) = namespace-uri($buyer_id)
    return
        $a/ma:AuctionHomepage
  }
</Q7> 
%%%declare namespace ma = "http://www.example.com/AuctionWatch";

<Q8 xmlns:ma="http://www.example.com/AuctionWatch"
    xmlns:eachbay="http://www.example.com/auctioneers#eachbay" 
    xmlns:xlink="http://www.w3.org/1999/xlink">
  {
    for $s in doc("auction.xml")//ma:Trading_Partners/(ma:Seller | ma:High_Bidder)
    where $s/*:NegativeComments = 0
    return $s
  }
</Q8>
%%%declare function local:one_level($p as element()) as element()
{
    <part partid="{ $p/@partid }"
          name="{ $p/@name }" >
        {
            for $s in doc("partlist.xml")//part
            where $s/@partof = $p/@partid
            return local:one_level($s)
        }
    </part>
};

<parttree>
  {
    for $p in doc("partlist.xml")//part[empty(@partof)]
    return local:one_level($p)
  }
</parttree>
%%%import schema namespace ipo = "http://www.example.com/IPO" at "ipo.xsd";
                        
count( 
  doc("ipo.xml")//shipTo[. instance of element(*, ipo:UKAddress)]
)
                            
%%%1
%%%module namespace z="http://www.example.com/xq/zips";
import schema namespace ipo = "http://www.example.com/IPO" at "ipo.xsd";
import schema namespace zips = "http://www.example.com/zips" at "zips.xsd";

declare function z:zip-ok($a as element(*, ipo:USAddress))
  as xs:boolean
{ 
  some $i in doc("zips.xml")/zips:zips/element(zips:row)
  satisfies $i/zips:city = $a/city
        and $i/zips:state = $a/state
        and $i/zips:zip = $a/zip
 }; 
%%%module namespace p="http://www.example.com/xq/postals";
import schema namespace ipo = "http://www.example.com/IPO" at "ipo.xsd";
import schema namespace pst = "http://www.example.com/postals" at "postals.xsd";

declare function p:postal-ok($a as element(*, ipo:UKAddress))
  as xs:boolean
{
  some $i in doc("postals.xml")/pst:postals/element(pst:row)
  satisfies $i/pst:city = $a/city
       and starts-with($a/postcode, $i/pst:prefix)
}; 
%%%import schema namespace ipo="http://www.example.com/IPO" at "ipo.xsd";
import schema namespace pst="http://www.example.com/postals" at "postals.xsd";
import schema namespace zips="http://www.example.com/zips" at "zips.xsd";

import module namespace zok="http://www.example.com/xq/zips";
import module namespace pok="http://www.example.com/xq/postals";

declare function local:address-ok($a as element(*, ipo:Address))
 as xs:boolean
{
  typeswitch ($a)
      case $zip as element(*, ipo:USAddress)
           return zok:zip-ok($zip)
      case $postal as element(*, ipo:UKAddress )
           return pok:postal-ok($postal) 
      default return false()
};

let $shipTo := doc("ipo.xml")/element(ipo:purchaseOrder)/shipTo
let $billTo := doc("ipo.xml")/element(ipo:purchaseOrder)/billTo
return local:address-ok($shipTo) and local:address-ok($billTo)

%%%true
%%%import schema namespace ipo="http://www.example.com/IPO" at "ipo.xsd";

declare function local:names-match( $s as element(shipTo, ipo:Address), 
                                    $b as element(billTo, ipo:Address))
  as xs:boolean
{
     $s/name = $b/name
};

let $p := doc("ipo.xml")/element(ipo:purchaseOrder)
return local:names-match( $p/shipTo, $p/billTo ) 
%%%false
%%%import schema namespace ipo="http://www.example.com/IPO" at "ipo.xsd";

let $p := doc("ipo.xml")//element(ipo:purchaseOrder)
let $billTo := $p/billTo
let $shipTo := $p/shipTo
return
   if ($billTo instance of element(*, ipo:USAddress))
     then every $i in $p/items/item 
	      satisfies (exists($i/USPrice))
	 else false()
%%%true
%%%import schema namespace ipo="http://www.example.com/IPO" at "ipo.xsd";

declare function local:comment-text($c as schema-element(ipo:comment))
  as xs:string
{
    xs:string( $c )
};

for $p in doc("ipo.xml")//element(ipo:purchaseOrder),
    $t in local:comment-text( $p//ipo:shipComment )
where $p/shipTo/name="Helen Zoe"
    and $p/@orderDate = xs:date("1999-12-01")
return $t 
%%%import schema namespace ipo="http://www.example.com/IPO" at "ipo.xsd";

declare function local:comment-text($c as schema-element(ipo:comment))
  as xs:string
{
    xs:string( $c )
};

for $p in doc("ipo.xml")/schema-element(ipo:purchaseOrder)
where $p/shipTo/name="Helen Zoe"
  and $p/@orderDate = xs:date("1999-12-01")
return local:comment-text( $p//ipo:customerComment ) 
%%%import schema namespace ipo="http://www.example.com/IPO" at "ipo.xsd";

for $p in doc("ipo.xml")//element(ipo:purchaseOrder)
where $p/shipTo/name="Helen Zoe"
  and $p/@orderDate = xs:date("1999-12-01")
return $p//schema-element(ipo:comment)
                        
%%%import schema namespace ipo="http://www.example.com/IPO" at "ipo.xsd";

declare function local:comments-for-element( $e as element() )
  as element(ipo:comment)*
{
  $e/schema-element(ipo:comment)
};

for $p in doc("ipo.xml")//element(ipo:purchaseOrder)
where $p/shipTo/name="Helen Zoe"
  and $p/@orderDate = xs:date("1999-12-01")
return 
  <comments name="{$p/shipTo/name}" date="{$p/@orderDate}">
   {
     local:comments-for-element( $p )
   }
   {
     for $i in $p//item
     return local:comments-for-element( $i )
   }
  </comments> 
%%%import schema namespace ipo="http://www.example.com/IPO" at "ipo.xsd";

declare function local:deadbeat( $b as element(billTo, ipo:USAddress) )
  as xs:boolean
{
   $b/name = doc("deadbeats.xml")/deadbeats/row/name
}; 

for $p in doc("ipo.xml")//element(ipo:purchaseOrder)
where local:deadbeat( $p/element(billTo) )
return <warning>{ string($p/billTo/name) } is a known deadbeat!</warning>
                        
%%%module namespace c="http://www.example.com/calc";
import schema namespace ipo="http://www.example.com/IPO" at "ipo.xsd";

declare function c:total-price( $i as element(item)* )
  as xs:decimal
{
  let $subtotals := for $s in $i return $s/quantity * $s/USPrice
  return sum( $subtotals )
}; 
%%%import schema namespace ipo="http://www.example.com/IPO" at "ipo.xsd";
import module namespace calc = "http://www.example.com/calc";

for $p in doc("ipo.xml")//element(ipo:purchaseOrder)
where $p/shipTo/name="Helen Zoe"
   and $p/@orderDate = xs:date("1999-12-01")
return calc:total-price($p//item) 
%%%
<purchaseReport
  xmlns="http://www.example.com/Report"
  period="P3M" periodEnding="1999-12-31">

 <regions>
  <zip code="95819">
   <part number="872-AA" quantity="1"/>
   <part number="926-AA" quantity="1"/>
   <part number="833-AA" quantity="1"/>
   <part number="455-BX" quantity="1"/>
  </zip>
  <zip code="63143">
   <part number="455-BX" quantity="4"/>
  </zip>
 </regions>

 <parts>
  <part number="872-AA">Lawnmower</part>
  <part number="926-AA">Baby Monitor</part>
  <part number="833-AA">Lapis Necklace</part>
  <part number="455-BX">Sturdy Shelves</part>
 </parts>

</purchaseReport> 
%%%declare namespace rpt="http://www.example.com/Report";

let $orders := doc('ipo.xml')/schema-element(ipo:purchaseOrder)
                  [@orderDate ge xs:date("1999-09-01")
                   and @orderDate le xs:date("1999-12-31")]
let $items := $orders/items/item
let $zips := distinct-values($orders/billTo/zip)
let $parts := distinct-values($items/@partNum)
return
 <rpt:purchaseReport>
  <rpt:regions>
    {
     for $zip in $zips
     order by $zip
     return
      <rpt:zip code="{$zip}">
       {
        for $part in $parts
        let $hits := $orders[ billTo/zip = $zip and items/item/@partNum = $part]
        let $quantity := sum($hits//item[@partNum=$part]/quantity)
        where count($hits) > 0
        order by $part
        return
         <rpt:part number="{$part}" quantity="{$quantity}"/>
       }
      </rpt:zip>
    }
  </rpt:regions>
  <rpt:parts>
   {
     for $part in $parts
     return
      <rpt:part number="{$part}">
       {
         string($items[@partNum = $part]/productName)
       }
      </rpt:part>   
   }
  </rpt:parts>
</rpt:purchaseReport>
            
%%%