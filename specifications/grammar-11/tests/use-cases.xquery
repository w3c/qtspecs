declare default collation "http://mycollations";

<bib>
 {
  for $b in document("http://www.bn.com")/bib/book
  where $b/publisher = "Addison-Wesley" and $b/@year > 1991
  return
    <book year="{ $b/@year }">
     { $b/title }
    </book>
 }
</bib>


%%%
element div {baz}
%%%
element div baz
%%%

<bib>
    <book year="1994">
        <title>TCP/IP Illustrated</title>
    </book>
    <book year="1992">
        <title>Advanced Programming in the Unix environment</title>
    </book>
</bib>


%%%


<results>
  {
    for $b in document("http://www.bn.com")/bib/book,
        $t in $b/title,
        $a in $b/author
    return
        <result>
            { $t }    
            { $a }
        </result>
  }
</results>


%%%

<results>
  {
    for $b in document("http://www.bn.com")/bib/book
    return
        <result>
            { $b/title }
            {
                for $a in $b/author
                return $a
            }
        </result>
  }
</results>


%%%


<results>
  {
    for $a in distinct-values(document("http://www.bn.com")//author)
    return
        <result>
            { $a }
            {
                for $b in document("http://www.bn.com")/bib/book[value-equals(author,$a)]
                return $b/title
            }
        </result>
  }
</results>


%%%


<books-with-prices>
  {
    for $b in document("www.bn.com/bib.xml")//book,
        $a in document("www.amazon.com/reviews.xml")//entry
    where $b/title = $a/title
    return
        <book-with-prices>
            { $b/title }
            <price-amazon>{ $a/price/text() }</price-amazon>
            <price-bn>{ $b/price/text() }</price-bn>
        </book-with-prices>
  }
</books-with-prices>


%%%


<bib>
  {
    for $b in document("www.bn.com/bib.xml")//book
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


%%%


<bib>
  {
    for $b in document("www.bn.com/bib.xml")//book[publisher = "Addison-Wesley" and @year > "1991"] 
 order by (title)
    return
        <book>
            { $b/@year }
            { $b/title }
        </book>
  }
</bib>


%%%


<bib>
  {
    for $b in document("www.bn.com/bib.xml")//book[publisher = "Addison-Wesley" and @year > "1991"] 
 order by stable (title)
    return
        <book>
            { $b/@year }
            { $b/title }
        </book>
  }
</bib>


%%%


for $b in document("www.bn.com/bib.xml")//book,
    $e in $b/*[contains(string(.), "Suciu")]
where ends_with(name($e), "or")
return
    <book>
        { $b/title }
        { $e }
    </book>
  

%%%


<results>
  {
    for $t in document("books.xml")//chapter/title union document("books.xml")//section/title
    where contains($t/text(), "XML")
    return $t
  }
</results>


%%%


<results>
  {
    let $doc := document("prices.xml")
    for $t in distinct-values($doc/book/title)
    let $p := $doc/book[title = $t]/price
    return
      <minprice title="{ $t/text() }">
         { 
           min($p) 
         }
      </minprice>
  }
</results>


%%%


<bib>
    {
        for $b in document("www.bn.com/bib.xml")//book[author]
        return
            <book>
                { $b/title }
                { $b/author }
            </book>
    }
    {
        for $b in document("www.bn.com/bib.xml")//book[editor]
        return
            <reference>
                { $b/title }
                <org>{ $b/editor/affiliation/text() }</org>
            </reference>
    }
</bib>


%%%


<bib>
  {
    for $book1 in document("www.bn.com/bib.xml")//book,
        $book2 in document("www.bn.com/bib.xml")//book
    where $book1/title/text() > $book2/title/text() 
    and bags-are-equal($book1/author, $book2/author) 
    return
        <book-pair>
            { $book1/title }
            { $book2/title }
        </book-pair>
  }
</bib>


%%%



<toc>
  {
    let $b := document("book1.xml")
    return
        filter($b//section | $b//section/title | $b//section/title/text())
  }
</toc>


%%%


<figlist>
  {
    for $f in document("book1.xml")//figure
    return
        <figure>
            { $f/@* }
            { $f/title }
        </figure>
  }
</figlist>


%%%


<section_count>{ count(document("book1.xml")//section) }</section_count>, 
<figure_count>{  count(document("book1.xml")//figure ) }</figure_count>


%%%


<section_count>7</section_count>,
<figure_count>3</figure_count>


%%%


<top_section_count>
 { 
   count(document("book1.xml")/book/section) 
 }
</top_section_count>


%%%


<top_section_count>2</top_section_count>


%%%


<section_list>
  {
    for $s in document("book1.xml")//section
    let $f := $s/figure
    return
        <section title="{ $s/title/text() } figcount={ count($f) }"/>
  }
</section_list>


%%%


declare function section_summary($s as element()) as element()
{
    <section>
        { $s/@* }
        { $s/title }
        <figcount>{ count($s/figure) }</figcount>
        {
            for $ss in $s/section
            return section_summary($ss)
        }
    </section>
};

<toc>
  {
    for $s in document("book1.xmll")//section
    return section_summary($s)
  }
</toc>


%%%


for $s in document("report1.xml")//section[section.title = "Procedure"]
return ($s//incision)[2]/instrument


%%%


for $s in document("report1.xml")//section[section.title = "Procedure"]
return ($s//instrument)[position()<=2]


%%%


<result>
  {
    for $i in document("items.xml")//item_tuple
    where $i/start_date <= date()
      and $i/end_date >= date() 
      and contains($i/description, "Bicycle")
    order by (itemno)
    return
        <item_tuple>
            { $i/itemno }
            { $i/description }
        </item_tuple>
  }
</result>


%%%


<result>
  {
    for $i in document("items.xml")//item_tuple
    let $b := document("bids.xml")//bid_tuple[itemno = $i/itemno]
    where contains($i/description, "Bicycle")
    order by(itemno)
    return
        <item_tuple>
            { $i/itemno }
            { $i/description }
            <high_bid>{ max($b/bid) }</high_bid>
        </item_tuple>
  }
</result>


%%%


<result>
  {
    for $u in document("users.xml")//user_tuple
    for $i in document("items.xml")//item_tuple
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


%%%


<result>
  {
    for $i in document("items.xml")//item_tuple
    where not(some $b in document("bids.xml")//bid_tuple 
                        satisfies $b/itemno = $i/itemno)
    return
        <no_bid_item>
            { $i/itemno }
            { $i/description }
        </no_bid_item>
  }
</result>


%%%


<result>
  {
    for $seller in document("users.xml")//user_tuple,
        $buyer in  document("users.xml")//user_tuple,
        $item in  document("items.xml")//item_tuple,
        $highbid in  document("bids.xml")//bid_tuple
    where $seller/name = "Tom Jones" 
      and $seller/userid = $item/offered_by 
      and contains($item/description, "Bicycle") 
      and $item/itemno = $highbid/itemno 
      and $highbid/userid = $buyer/userid 
      and $highbid/bid = max(document("bids.xml")//bid_tuple [itemno = $item/itemno]/bid)
    order by(itemno)
    return
        <jones_bike>
            { $item/itemno }
            { $item/description }
            <high_bid>{ $highbid/bid }</high_bid>
            <high_bidder>{ $buyer/name }</high_bidder>
        </jones_bike>
  }
</result>


%%%


<result>
  {
    for $seller in unordered(document("users.xml")//user_tuple),
        $buyer in  unordered(document("users.xml")//user_tuple),
        $item in  unordered(document("items.xml")//item_tuple),
        $highbid in  unordered(document("bids.xml")//bid_tuple)
    where $seller/name = "Tom Jones" 
      and $seller/userid = $item/offered_by 
      and contains($item/description, "Bicycle") 
      and $item/itemno = $highbid/itemno 
      and $highbid/userid = $buyer/userid 
      and $highbid/bid = max(document("bids.xml")//bid_tuple [itemno = $item/itemno]/bid)
    order by (itemno)
    return
        <jones_bike>
            { $item/itemno }
            { $item/description }
            <high_bid>{ $highbid/bid }</high_bid>
            <high_bidder>{ $buyer/name }</high_bidder>
        </jones_bike>
  }
</result>

%%%
<a>{<q/><<<r/>}</a>><b>></b>
%%%
<a>{<q/><<<r/>}</a>< <b>></b>
%%%


<result>
  {
    for $item in document("items.xml")//item_tuple
    let $b := document("bids.xml")//bid_tuple[itemno = $item/itemno]
    where $item/reserve_price * 2 < max($b/bid)
    return
        <successful_item>
            { $item/itemno }
            { $item/description }
            { $item/reserve_price }
            <high_bid>{ max($b/bid) }</high_bid>
        </successful_item>
 }
</result>


%%%


let $allbikes := document("items.xml")//item_tuple[contains(description, "Bicycle") or contains(description, "Tricycle")]
let $bikebids := document("bids.xml")//bid_tuple[itemno = $allbikes/itemno]
return
    <high_bid>
      { 
        max($bikebids/bid) 
      }
    </high_bid>

%%%


let $item := document("items.xml")//item_tuple
  [end_date >= date("1999-03-01") and end_date <= date("1999-03-31")]
return
    <item_count>
      { 
        count($item) 
      }
    </item_count>


%%%


<result>
  {
    let $end_dates := document("items.xml")//item_tuple/end_date
    for $m in distinct-values(month($end_dates))
    let $item := document("items.xml")
        //item_tuple[year(end_date) = 1999 and month(end_date) = $m]
    order by(month)
    return
        <monthly_result>
            <month>{ $m }</month>
            <item_count>{ count($item) }</item_count>
        </monthly_result>
  }
</result>


%%%


<result>
  {
    for $highbid in document("bids.xml")//bid_tuple,
        $user in document("users.xml")//user_tuple
    where $user/userid = $highbid/userid 
      and $highbid/bid = max(document("bids.xml")//bid_tuple[itemno = $highbid/itemno]/bid)
    order by(itemno)
    return
        <high_bid>
            { $highbid/itemno }
            { $highbid/bid }
            <bidder>{ $user/name/text() }</bidder>
        </high_bid>
  }
</result>


%%%


let $highbid := max(document("bids.xml")//bid_tuple/bid)
return
    <result>
      {
        for $item in document("items.xml")//item_tuple,
            $b in document("bids.xml")//bid_tuple[itemno = $item/itemno]
        where $b/bid = $highbid
        return
            <expensive_item>
                { $item/itemno }
                { $item/description }
                <high_bid>{ $highbid }</high_bid>
            </expensive_item>
      }
    </result>


%%%


declare function bid_summary ()
{
    for $i in distinct-values(document("bids.xml")//itemno)
    let $b := document("bids.xml")//bid_tuple[itemno = $i]
    return
        <bid_count>
            { $i }
            <nbids>{ count($b) }</nbids>
        </bid_count>
};

<result>
 {
    let $bid_counts := bid_summary(),
        $maxbids := max($bid_counts/nbids),
        $maxitemnos := $bid_counts[nbids=$max_bids]
    for $item in document("items.xml")//item_tuple,
        $bc in $bid_counts
    where $bc/nbids = $maxbids and $item/itemno = $bc/itemno
    return
        <popular_item>
            { $item/itemno }
            { $item/description }
            <bid_count>{ $bc/nbids/text() }</bid_count>
        </popular_item>
 }
</result>


%%%


<result>
  {
    for $uid in distinct-values(document("bids.xml")//userid),
        $u in document("users.xml")//user_tuple[userid = $uid]
    let $b := document("bids.xml")//bid_tuple[userid = $uid]
    order by(userid)
    return
        <bidder>
            { $u/userid }
            { $u/name }
            <bidcount>{ count($b) }</bidcount>
            <avgbid>{ avg($b/bid) }</avgbid>
        </bidder>
  }
</result>


%%%


<result>
  {
    for $i in distinct-values(document("bids.xml")//itemno)
    let $b := document("bids.xml")//bid_tuple[itemno = $i]
    where count($b) >= 3
    order by avgbid descending
    return
        <popular_item>
            { $i }
            <avgbid>{ avg($b/bid) }</avgbid>
        </popular_item>
  }
</result>


%%%


<result>
  {
    for $u in document("users.xml")//user_tuple
    let $b := document("bids.xml")//bid_tuple[userid = $u/userid and bid >= 100]
    where count($b) > 1
    return
        <big_spender>{ $u/name/text() }</big_spender>
  }
</result>


%%%


<result>
  {
    for $u in document("users.xml")//user_tuple
    let $b := document("bids.xml")//bid_tuple[userid = $u/userid]
    order by(userid)
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


%%%


<frequent_bidder>
  {
    for $u in document("users.xml")//user_tuple
    where 
      every $item in document("items.xml")//item_tuple satisfies 
        some $b in document("bids.xml")//bid_tuple satisfies 
          ($item/itemno = $b/itemno and $u/userid = $b/userid)
    return
        $u/name
  }
</frequent_bidder>


%%%



<result>
  {
    for $u in document("users.xml")//user_tuple
    order by(name)
    return
        <user>
            { $u/name }
            {
                for $b in distinct-values(document("bids.xml")//bid_tuple[userid = $u/userid]/itemno),
                    $i in document("items.xml")//item_tuple[itemno = $b]
                    order by description/text()
                return
                    <bid_on_item>{ $i/description/text() }</bid_on_item>
            }
        </user>
  }
</result>


%%%


<result>
  { 
    //report//para 
  }
</result>


%%%


<result>
  { 
    //intro/para 
  }
</result>


%%%


<result>
  {
    for $c in //chapter
    where empty($c/intro)
    return $c/section/intro/para
  }
</result>


%%%


<result>
  { 
    (((//chapter)[2]//section)[3]//para)[2] 
  }
</result>


%%%


<result>
  { 
    //para[@security = "c"] 
  }
</result>


%%%


<result>
  {
    for $s in //section/@shorttitle
    return <stitle>{ $s }</stitle>
  }
</result>


%%%


<result>
  {
    for $i in //intro/para[1]
    return
        <first_letter>{ substring(string($i), 1, 1) }</first_letter> 
  }
</result>


%%%


<result>
  { 
    //section[contains(string(.//title), "is SGML")] 
  }
</result>


%%%


<result>
  { 
    //section[contains(.//title/text(), "is SGML")] 
  }
</result>


%%%


<result>
  {
    for $id in document("input.xml")//xref/@xrefid
    return //topic[@topicid = $id]
  }
</result>


%%%


//news_item/title[contains(./text(), "Foobar Corporation")]


%%%


let $foobar_partners := //company[name = "Foobar Corporation"]//partner
for $item in //news_item
where 
  some $t in $item//title satisfies 
    (contains($t/text(), "Foobar Corporation") 
    and (some $partner in $foobar_partners satisfies 
      contains($t/text(), $partner/text())) 
  or (some $par in $item//par satisfies 
   (contains($par/text(), "Foobar Corporation") 
     and (some $partner in $foobar_partners satisfies 
       contains($par/text(), $partner/text())))))
return
    <news_item>
        { $item/title }
        { $item/date }
    </news_item>


%%%


let $foobar_partners := //company[name = "Foobar Corporation"]//partner,
    $foobar_competitors := //company[name = "Foobar Corporation"]//competitor
for $item in //news_item
where some $partner in $foobar_partners satisfies 
  contains_in_same_sentence(string($item/content), "Foobar Corporation", $partner/text()) 
      and not(some $competitor in $foobar_competitors satisfies 
                   contains(string($item/content), $competitor/text()))
return
    $item/title


%%%



for $item in //news_item,
    $c in //company
let $partners := $c//partner
where contains(string($item), $c/name/text()) 
  and (some $p in $partners satisfies 
    contains(string($item), $p/text()) and $item/news_agent != $c/name)
return
    $item


%%%


for $item in //news_item
where contains(string($item/content), "Gorilla Corporation")
return
    <item_summary>
        { $item/title/text() }.
        { $item/date/text() }.
        { string(($item//par)[1]) }
    </item_summary>


%%%


let $companies := distinct-values(//company/name/text() 
       union //company//partner/text() 
       union //company//competitor/text())
for $item in //news_item,
    $item_title in $item/title,
    $item_para in $item//par,
    $c1 in $companies,
    $c2 in $companies
where $c1 != $c2 
  and contains_stems_in_same_sentence($item_title/text(), $c1, $c2, "acquire") 
   or contains_stems_in_same_sentence($item_para/text(), $c1, $c2, "acquire")
return
    distinct-values($item)


%%%


<Q1>
  {
    for $n in distinct-values(get-namespace-uri(//*))
    return
        <ns>{$n}</ns>
  }
</Q1>

%%%


declare namespace music = "http://www.example.org/music/records";

<Q2>
  { 
    //music:title 
  }
</Q2>


%%%


declare namespace dt = "http://www.w3.org/1999/XMLSchema-datatypes";

<Q3>
  { 
    //*[@dt:*] 
  }
</Q3>


%%%


declare namespace xlink = "http://www.w3.org/1999/xlink";

<Q4>
  {
    for $hr in //@xlink:href
    return <ns>{ $hr }</ns>
  }
</Q4>

%%%


declare namespace music = "http://www.example.org/music/records";

<Q5>
  { 
     //music:record[music:remark/@xml:lang = "de"]
  }
</Q5>


%%%



declare namespace ma = "http://www.example.com/AuctionWatch";
declare namespace anyzone = "http://www.example.com/auctioneers#anyzone";

<Q6>
  { 
    //ma:Auction[@anyzone:ID]/ma:Schedule/ma:Close 
  }
</Q6>


%%%


declare namespace ma = "http://www.example.com/AuctionWatch";

<Q7>
  {
    for $a in //ma:Auction
    let $seller_id := $a/ma:Trading_Partners/ma:Seller/*:ID,
        $buyer_id := $a/ma:Trading_Partners/ma:High_Bidder/*:ID
    where namespace_uri($seller_id) = namespace_uri($buyer_id)
    return
        $a/ma:AuctionHomepage
  }
</Q7>


%%%


declare namespace ma = "http://www.example.com/AuctionWatch";

<Q8>
  {
    (for $s in //ma:Trading_Partners/ma:Seller
     where $s/*:NegativeComments = 0
     return $s)
  union 
    (for $b in //ma:Trading_Partners/ma:High_Bidder
     where $b/*:NegativeComments = 0
     return $b)
  }
</Q8>


%%%


declare function one_level ($p as element()) as element()
{
    <part partid="{ $p/@partid }" 
          name="{ $p/@name }" >
        {
            for $s in document("data/parts-data.xml")//part
            where $s/@partof = $p/@partid
            return one_level($s)
        }
    </part>
};

<parttree>
  {
    for $p in document("data/parts-data.xml")//part[empty(@partof)]
    return one_level($p)
  }
</parttree>


%%%


<result>
  {
    for $m in document("census.xml")//person[name = "Martha"]
    return shallow($m/@spouse->person)
  }
</result>


%%%


declare function children($p as element()) 
{
    shallow($p/person) union shallow($p/@spouse->person/person)
};

<result>
  {
    for $j in document("census.xml")//person[name = "Joe"]
    return children($j)
  }
</result>


%%%


<result>
  {
    for $p in document("census.xml")//person,
        $s in $p/@spouse->person
    where $p/person/job = "Athlete" or $s/person/job = "Athlete"
    return shallow($p)
  }
</result>


%%%


<result>
  {
    for $p in document("census.xml")//person,
        $c in $p/person
    where $p/job = $c/job or //person/job[$p/@spouse] = $c/job
    return shallow($c)
  }
</result>


%%%


<result>
    {
        for $p in document("census.xml")//person,
            $c in $p/person[job = $p/job]
        return
            <match parent="{ $p/name }" child="{ $c/name }" job="{ $c/job }" />
    }
    {
        for $p in document("census.xml")//person,
            $c in $p/@spouse->person/person[job = $p/job]
        return
            <match parent="{ $p/name }" child="{ $c/name }" job="{ $c/job }" />
    }
</result>


%%%


<result>
  {
    for $b in document("census.xml")//person[name = "Bill"],
        $c in $b/person | $b/@spouse->person/person,
        $g in $c/person | $c/@spouse->person/person
    return shallow($g)
  }
</result>


%%%


<result>
  {
    for $b in document("census.xml")//person,
        $c in $b/person | $b/@spouse->person/person,
        $g in $c/person | $c/@spouse->person/person
    return
        <grandparent name="{ $b/name }" grandchild="{ $g/name }"/>
  }
</result>


%%%


<result>
  {
    for $s in document("census.xml")//person[name = "Dave"]/@spouse->person,
        $sp in $s/.. | $s/../@spouse->person
    return
        shallow($sp)
  }
</result>


%%%


<result>
  {
    for $p in document("census.xml")//person
    where empty(children($p))
    return shallow($p)
  }
</result>


%%%


<result>
  {
    for $p in document("census.xml")//person[person]
    where empty($p/@spouse->person)
    return shallow($p)
  }
</result>


%%%


declare function descrip ($e as element()) as element()
{
    let $kids := $e/* union $e/@spouse->person/*
    let $mstatus :=  if ($e[@spouse]) then "Yes" else "No"
    return
        <person married="{ $mstatus }" nkids="{ count($kids) }">{ $e/@name/text() }</person>
};

declare function descendants ($e as element())
{
    if (empty($e/* union $e/@spouse->person/*))
    then $e
    else $e union descendants($e/* union $e/@spouse->person/*)
};

for $x in descrip(descendants(//person[name = "Joe"])) 
order by @nkids descending 
return $x

%%%
element(*, ipo:Address)
%%%
element(*, ipo:Address?)
%%%
element(*)
%%%
element()
%%%
attribute(*)
%%%
attribute(*, xs:integer)
%%%
attribute()
%%%


declare function code($a as element(*, ipo:Address)) as string
   {
   typeswitch ($a)
      case element(*, ipo:ZUSAddress)
           return ($a treat as ipo:USAddress)/zip/data()
      case element(*, ipo:XUKAddress)
           return ($a treat as ipo:UKAddress)/postcode/data()
      default return 'none'
   };

code(addr)


%%%

declare default collation "http://mycollations";

import schema "ipo.xsd";
declare namespace ipo="http://www.example.com/IPO";
						
count( 
  input()//ipo:shipTo[. instance of element(*, ipo:UKAddress)]
)


%%%

module namespace mylib = "check-ok";

import schema "ipo.xsd";
import schema "zips.xsd";
declare namespace ipo="http://www.example.com/IPO";

declare function zip-ok($a as element(*, ipo:USAddress))
  as xs:boolean
{
  let $zip :=
     for $i in document("zips.xml")/zips/row
     where $i/city = $a/city
       and $i/state = $a/state
       and $i/zip = $a/zip
     return $i
  return exists( $zip )
};


%%%

module namespace mylib = "check-ok";

import schema "ipo.xsd";
import schema "postals.xsd";
declare namespace ipo="http://www.example.com/IPO";

declare function postal-ok($a as element(*, ipo:UKAddress))
  as xs:boolean
{
  let $pc :=
     for $i in document("zips.xml")/zips/row
     where $i/city = $a/city
       and $i/postcode = $a/postcode
     return $i
  return exists( $pc )
} ;


%%%


import schema "ipo.xsd";
declare namespace ipo="http://www.example.com/IPO";

declare function address-ok( $a as element(*, ipo:Address))
 as xs:boolean
{
  typeswitch ($a)
      case $b as element(*, ipo:USAddress)
           return zip-ok($b/shipTo)         
      case $b as element(*, ipo:UKAddress)
           return postal-ok($b)
      default return false()
};

for $p in collection("ipo")//ipo:purchaseOrder
where not( address-ok($p/shipTo) and address-ok($p/billTo))
return $p


%%%


import schema "ipo.xsd";
declare namespace ipo="http://www.example.com/IPO";

declare function names-match( $s as element(ipo:shipTo), $b as element(ipo:billTo) )
  as boolean
 {
     $s/name = $b/name
 };
 
 for $p in input()//ipo:purchaseOrder
 where not( names-match( $p/ipo:shipTo, $p/ipo:billTo ) )
 return $p


%%%


import schema "ipo.xsd";
declare namespace ipo="http://www.example.com/IPO";

for $p in input()//ipo:purchaseOrder,
      $s in $i/ipo:shipTo
where not( $s instance of element(*, ipo:USAddress)) 
     and exists( $p//ipo:USPrice )
return $p


%%%


import schema "ipo.xsd";
declare namespace ipo="http://www.example.com/IPO";

declare function comment-text($c as element(ipo:comment))
  as xs:string
{
	string( $c )
};

for $p in input()//ipo:purchaseOrder
where $p/ipo:shipTo/ipo:name="Helen Zoe"
    and $p/ipo:orderDate = date("1999-12-01")
return comment-text( $p//ipo:shipComment )


%%%


for $p in input()//ipo:purchaseOrder
where $p/ipo:shipTo/ipo:name="Helen Zoe"
  and $p/ipo:orderDate = date("1999-12-01")
return comment-text( $p//ipo:customerComment )


%%%


import schema "ipo.xsd";
declare namespace ipo="http://www.example.com/IPO";

for $p in input()//ipo:purchaseOrder
where $p/ipo:shipTo/ipo:name="Helen Zoe"
  and $p/ipo:orderDate = date("1999-12-01")
return ($p//ipo:customerComment  | $p//ipo:shipComment  | $p//ipo:comment )


%%%

module namespace mylib = "test";

import schema "ipo.xsd";
declare namespace ipo="http://www.example.com/IPO";

declare function comments-for-element( $e as element(*))
  as ipo:comment*
{
  let $c := $e/(ipo:customerComment  | $p//ipo:shipComment | ipo:comment)
  return $c
};


%%%

module namespace mylib = "test";

import schema "ipo.xsd";
declare namespace ipo="http://www.example.com/IPO";

declare function deadbeat( $b as element(billTo, USAddress))
  as xs:boolean
{
   $b/ipo:name = document("www.usa-deadbeats.com/current")/deadbeats/row/name
};


%%%

module namespace mylib = "test";

import schema "ipo.xsd";
declare namespace ipo="http://www.example.com/IPO";

declare function total-price( $i as element(ipo:item)* )
  as xs:decimal
{
  let $subtotals := for $s in $i return $s/quantity * $s/ipo:USPrice
  return sum( $subtotals )
};


%%%


import schema "ipo.xsd";
declare namespace ipo="http://www.example.com/IPO";

for $p in input()//ipo:purchaseOrder
where $p/ipo:shipTo/ipo:name="Helen Zoe"
   and $p/ipo:orderDate = date("1999-12-01")
return total-price($p)


%%%


declare function  one() as integer
{1};

one()


%%%


declare function identity( $x as element()*) 
	as element()* {$x} ;

identity(<a/>)


%%%


declare function identity($x as element()+) 
	as element()+ {$x} ;

identity(<a/>)


%%%


declare function identity($x as element()?) 
	as element()? {$x};

identity(<a/>)


%%%


text {a/b/c[23]}, 
element foo {yada}, 
element {@foo} {yada}, 
attribute foo {yada}, 
attribute {@foo} {yada}, 
text {a/b/c[23]}


%%%

amp,
ancestor,
ancestor-or-self,
and,
apos,
as,
ascending,
at,
atomic,
attribute,
by,
case,
cast,
child,
collation,
collation,
comment,
context,
declare,
default,
define,
descendant,
descendant-or-self,
descending,
div,
document,
element,
else,
empty,
eq,
every,
except,
following,
following-sibling,
for,
function,
ge,
greatest,
gt,
gt,
id,
idiv,
if,
import,
in,
instance,
intersect,
is,
isnot,
item,
key,
le,
least,
let,
lt,
mod,
namespace,
ne,
none,
of,
or,
order,
parent,
preceding,
preceding-sibling,
preserve,
processing-instruction,
quot,
result,
return,
returns,
satisfies,
schema,
self,
some,
stable,
strip,
text,
then,
to,
treat,
type,
typeswitch,
union,
unordered,
untyped,
validate,
value,
where,
boundary-space

%%%

foo castable as xsd:integer

%%%

foo castable as xsd:integer?

%%%

deep-equal(/,foo)

%%%

amp(),
ancestor(),
ancestor-or-self(),
and(),
apos(),
as(),
ascending(),
at(),
atomic(),
attribute(),
by(),
case(),
cast(),
child(),
collation(),
collation(),
comment(),
context(),
declare(),
default(),
define(),
descendant(),
descendant-or-self(),
descending(),
div(),
document(),
element(),
else(),
(: void(), :)
eq(),
every(),
except(),
following(),
following-sibling(),
for(),
ge(),
greatest(),
gt(),
gt(),
idiv(),
import(),
in(),
instance(),
intersect(),
is(),
isnot(),
key(),
le(),
least(),
let(),
lt(),
mod(),
namespace(),
ne(),
none(),
of(),
or(),
order(),
parent(),
preceding(),
preceding-sibling(),
preserve(),
processing-instruction(),
quot(),
result(),
return(),
returns(),
satisfies(),
schema(),
self(),
some(),
stable(),
strip(),
text(),
then(),
to(),
treat(),
type(),
union(),
unordered(),
untyped(),
validate(),
value(),
where(),
boundary-space(),
element(),
attribute()

%%%

@amp,
@ancestor,
@ancestor-or-self,
@and,
@apos,
@as,
@ascending,
@at,
@atomic,
@attribute,
@by,
@case,
@cast,
@child,
@collation,
@collation,
@comment,
@context,
@declare,
@default,
@define,
@descendant,
@descendant-or-self,
@descending,
@div,
@document,
@element,
@else,
@empty,
@eq,
@every,
@except,
@following,
@following-sibling,
@for,
@function,
@ge,
@greatest,
@gt,
@gt,
@id,
@idiv,
@if,
@import,
@in,
@instance,
@intersect,
@is,
@isnot,
@item,
@key,
@le,
@least,
@let,
@lt,
@mod,
@namespace,
@ne,
@none,
@of,
@or,
@order,
@parent,
@preceding,
@preceding-sibling,
@preserve,
@processing-instruction,
@quot,
@result,
@return,
@returns,
@satisfies,
@schema,
@self,
@some,
@stable,
@strip,
@text,
@then,
@to,
@treat,
@type,
@typeswitch,
@union,
@unordered,
@untyped,
@validate,
@value,
@where,
@boundary-space

%%%

child::amp,
child::ancestor,
child::ancestor-or-self,
child::and,
child::apos,
child::as,
child::ascending,
child::at,
child::atomic,
child::attribute,
child::by,
child::case,
child::cast,
child::child,
child::collation,
child::collation,
child::comment,
child::context,
child::declare,
child::default,
child::define,
child::descendant,
child::descendant-or-self,
child::descending,
child::div,
child::document,
child::element,
child::else,
child::empty,
child::eq,
child::every,
child::except,
child::following,
child::following-sibling,
child::for,
child::function,
child::ge,
child::greatest,
child::gt,
child::gt,
child::id,
child::idiv,
child::if,
child::import,
child::in,
child::instance,
child::intersect,
child::is,
child::isnot,
child::item,
child::key,
child::le,
child::least,
child::let,
child::lt,
child::mod,
child::namespace,
child::ne,
child::none,
child::of,
child::or,
child::order,
child::parent,
child::preceding,
child::preceding-sibling,
child::preserve,
child::processing-instruction,
child::quot,
child::result,
child::return,
child::returns,
child::satisfies,
child::schema,
child::self,
child::some,
child::stable,
child::strip,
child::text,
child::then,
child::to,
child::treat,
child::type,
child::typeswitch,
child::union,
child::unordered,
child::untyped,
child::validate,
child::value,
child::where,
child::xmlspace

%%%

module namespace mylib = "test";
import schema default element namespace "http://example.com";
import schema namespace foo = "http://example.com";
import schema default element namespace "http://example.com" at "x";
import schema namespace foo = "http://example.com" at "x";

%%%

typeswitch(1)
case xs:integer* return "list of integers"
default return "something else"

%%%

1 treat as element(ns:bib)

%%%

typeswitch(1)
case empty-sequence() return "empty"
default return "something else"

%%%

declare construction preserve;
foo

%%%

declare construction strip;
foo

%%%
validate lax {foo}

%%%
validate strict {foo}

%%%
validate {foo}

%%%

<master-list>
 {
    for $s in document("suppliers.xml")//supplier
    order by $s/suppname
    return
        <supplier>
           { 
             $s/suppname,
             for $i in document("catalog.xml")//item
                     [suppno = $s/suppno],
                 $p in document("parts.xml")//part
                     [partno = $i/partno]
             order by $p/description
             return
                <part>
                   {
                     $p/description,
                     $i/price
                   }
                </part> 
           }
        </supplier> 
    ,
    (: parts that have no supplier :)
    <orphan-parts>
       { for $p in document("parts.xml")//part
         where empty(document("catalog.xml")//item
               [partno = $p/partno] )
         order by $p/description
         return $p/description 
       }
    </orphan-parts>
 }
</master-list>

%%%
declare copy-namespaces preserve, inherit;
import module namespace mylib = "yada.xquery";
import module namespace mylib = "yada2.xquery" at "http://example.org/yada2.xquery";
import module namespace yada2="yada2.xquery" at "http://example.org/yada2.xquery";
declare variable $x as xs:integer external;
declare variable $z as element(USAddress) := document("http://example.org/doc.xml");
declare function section_summary($s as element) as element external;
declare function addelements($x as element(foo)) as xs:integer external;
declare function addelements($x as element(foo)) as xs:integer external;

(yada)


%%%

       declare function name($e as element(person))
         as element(name)
       {
            $e/name
       };

       for $p in input()//element(person)
       return name($p)

%%%

       declare function name($e as element(person, surgeon))
         as element(name)
       {
            $e/name
       };


       for $p in input()//element(person, surgeon)
       return name($p)

%%%

      for $date in input()//element(*, xs:date)
      return <date>{ $date }</date>

%%%

declare function names-match(
    $s as element(ipo:shipTo),
    $b as element(ipo:billTo))
    as xs:boolean
{
        $s/ipo:name = $b/ipo:name
};

for $p in document("ipo.xml")//element(ipo:purchaseOrder)
where not( names-match( $p/ipo:shipTo, $p/ipo:billTo ) )
return $p

%%%

  element()

%%%

  element(*)

%%%

  element( person )

%%%

  element( person, personType? )

%%%

  element( *, xs:integer? )

%%%

  element( person )

%%%

  attribute()

%%%

  attribute( id )

%%%

  attribute( *, xs:integer )

%%%

  attribute( price, xs:integer )


%%%

declare namespace exq = "http://example.org/XQueryImplementation";

for $e in doc("employees.xml")//employee
order by (:: extension exq:RightToLeft ::) $e/lastname
return $e

%%%

declare namespace exq = "http://example.org/XQueryImplementation";

(:: pragma exq:timeout 12345 ::)

count(input()//author)


%%%

<bib>
 {
  for $b in document("http://www.bn.com")/bib/book
  where $b/publisher = "Addison-Wesley" and $b/@year > 1991
  return
    <book year="{ $b/@year }">
     { $b/title }
    </book>
 }
</bib>

%%%

(: ========================== :)
<bib>
  {
   for $b in document("http://www.bn.com/bib.xml")/bib/book
   where $b/publisher = "Addison-Wesley" and $b/@year > 1991
   return
     <book year="{ $b/@year }">
      { $b/title }
     </book>
  }
</bib> 
%%%
<results>
   {
     for $b in document("http://www.bn.com/bib.xml")/bib/book,
         $t in $b/title,
         $a in $b/author
     return
         <result>
             { $t }
             { $a }
         </result>
   }
</results>

%%%
<results>
{
     for $b in document("http://www.bn.com/bib.xml")/bib/book
     return
         <result>
             { $b/title }
             { $b/author  }
         </result>
}
</results> 
%%%
<results>
   {
     let $a := document("http://www.bn.com/bib/bib.xml")//author
     for $last in distinct-values($a/last),
         $first in distinct-values($a[last=$last]/first)
     return
         <result>
             { $last, $first }
             {
                 for $b in document("http://www.bn.com/bib.xml")/bib/book
                 where some $ba in $b/author
                       satisfies ($ba/last = $last and $ba/first=$first)
                 return $b/title
             }
         </result>
   }
</results> 
%%%
<books-with-prices>
   {
     for $b in document("http://www.bn.com/bib.xml")//book,
         $a in document("http://www.amazon.com/reviews.xml")//entry
     where $b/title = $a/title
     return
         <book-with-prices>
             { $b/title }
             <price-amazon>{ $a/price/text() }</price-amazon>
             <price-bn>{ $b/price/text() }</price-bn>
         </book-with-prices>
   }
</books-with-prices>
%%%
<bib>
   {
     for $b in document("http://www.bn.com/bib.xml")//book
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
%%%
<bib>
   {
     for $b in document("http://www.bn.com/bib.xml")//book
     where $b/publisher = "Addison-Wesley" and $b/@year > 1991
     order by $b/title
     return
         <book>
             { $b/@year }
             { $b/title }
         </book>
   }
</bib> 
%%%
for $b in document("http://www.bn.com/bib.xml")//book
let $e := $b/*[contains(string(.), "Suciu")
                and ends-with(local-name(.), "or")]
where exists($e)
return
     <book>
         { $b/title }
         { $e }
     </book> 
%%%
<results>
   {
     for $t in document("books.xml")//(chapter | section)/title
     where contains($t/text(), "XML")
     return $t
   }
</results> 
%%%
<results>
   {
     let $doc := document("docs/prices.xml")
     for $t in distinct-values($doc//book/title)
     let $p := $doc//book[title = $t]/price
     return
       <minprice title="{ $t }">
         <price>{ min($p) }</price>
       </minprice>
   }
</results> 
%%%
<bib>
{
         for $b in document("http://www.bn.com/bib.xml")//book[author]
         return
             <book>
                 { $b/title }
                 { $b/author }
             </book>
}
{
         for $b in document("http://www.bn.com/bib.xml")//book[editor]
         return
           <reference>
             { $b/title }
             {$b/editor/affiliation}
           </reference>
}
</bib>  
%%%
<bib>
{
     for $book1 in document("http://www.bn.com/bib.xml")//book,
         $book2 in document("http://www.bn.com/bib.xml")//book
     let $aut1 := for $a in $book1/author
                  order by $a/last, $a/first
                  return $a
     let $aut2 := for $a in $book2/author
                  order by $a/last, $a/first
                  return $a
     where $book1 << $book2
     and not($book1/title = $book2/title)
     and sequence-deep-equal($aut1, $aut2)
     return
         <book-pair>
             { $book1/title }
             { $book2/title }
         </book-pair>
}
</bib> 
%%%
declare function toc($book-or-section as element()) as element()*
{
         for $section in $book-or-section/section
         return
                 <section>
                 { $section/@* , $section/title , toc($section) 
}
                 </section>
};

<toc>
    {
      for $s in document("book.xml")/book return toc($s)
    }
</toc> 
%%%
<figlist>
   {
     for $f in document("book.xml")//figure
     return
         <figure>
             { $f/@* }
             { $f/title }
         </figure>
   }
</figlist> 
%%%
<section_count>{ count(document("book.xml")//section) 
}</section_count>,
<figure_count>{ count(document("book.xml")//figure) }</figure_count> 

%%%
<top_section_count>
  {
    count(document("book.xml")/book/section)
  }
</top_section_count>
%%%
<section_list>
   {
     for $s in document("book.xml")//section
     let $f := $s/figure
     return
         <section title="{ $s/title/text() }" figcount="{ count($f) }"/>
   }
</section_list> 
%%%
declare function section-summary($book-or-section as element())
   as element()*
{
   for $section in $book-or-section/section
   return
     <section>
        { $section/@* }
        { $section/title }
        <figcount>
         { count($section/figure) }
        </figcount>
        { section-summary($section) }
     </section>
};

<toc>
   {
     for $s in document("book.xml")/book/section
     return section-summary($s)
   }
</toc> 
%%%
for $s in document("report1.xml")//section[section.title = "Procedure"]
return ($s//incision)[2]/instrument
%%%
for $s in 
document("report1.xml")//section[section.title = "Procedure"]
return ($s//instrument)[position()<=2]
%%%
let $i2 := 
(document("report1.xml")//incision)[2]
for $a in (document("report1.xml")//action)[. >> $i2][position()<=2]
return $a//instrument 
%%%
for $p in 
document("report1.xml")//section[section.title = "Procedure"]
where not(some $a in $p//anesthesia satisfies
         $a << ($p//incision)[1] )
return $p 
%%%
declare function precedes($a as node(), $b as node()) as xs:boolean
{
     $a << $b
       and
     empty($a//node() intersect $b)
};


declare function follows($a as node(), $b as node()) as xs:boolean
{
     $a >> $b
       and
     empty($b//node() intersect $a)
};

<critical_sequence>
  {
   let $proc := document("report1.xml")//section[section.title="Procedure"][1]
   for $n in $proc//node()
   where follows($n, ($proc//incision)[1])
     and precedes($n, ($proc//incision)[2])
   return $n
  }
</critical_sequence> 
%%%
<critical_sequence>
  {
   let $proc := document("report1.xml")//section[section.title="Procedure"][1],
       $i1 :=  ($proc//incision)[1],
       $i2 :=  ($proc//incision)[2]
   for $n in $proc//node() except $i1//node()
   where $n >> $i1 and $n << $i2
   return $n
  }
</critical_sequence> 
%%%
<result>
   {
     for $i in document("items.xml")//item_tuple
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
%%%
<result>
   {
     for $i in document("items.xml")//item_tuple
     let $b := document("bids.xml")//bid_tuple[itemno = $i/itemno]
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
%%%
<result>
   {
     for $u in document("users.xml")//user_tuple
     for $i in document("items.xml")//item_tuple
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
%%%
<result>
   {
     for $i in document("items.xml")//item_tuple
     where empty(document("bids.xml")//bid_tuple[itemno = $i/itemno])
     return
         <no_bid_item>
             { $i/itemno }
             { $i/description }
         </no_bid_item>
   }
</result> 
%%%
<result>
   {
     for $seller in document("users.xml")//user_tuple,
         $buyer in  document("users.xml")//user_tuple,
         $item in  document("items.xml")//item_tuple,
         $highbid in  document("bids.xml")//bid_tuple
     where $seller/name = "Tom Jones"
       and $seller/userid  = $item/offered_by
       and contains($item/description , "Bicycle")
       and $item/itemno  = $highbid/itemno
       and $highbid/userid  = $buyer/userid
       and $highbid/bid = max(
                               document("docs/bids.xml")//bid_tuple
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
%%%
<result>
   {
    unordered (
     for $seller in document("users.xml")//user_tuple,
         $buyer in document("users.xml")//user_tuple,
         $item in document("items.xml")//item_tuple,
         $highbid in  document("bids.xml")//bid_tuple
     where $seller/name = "Tom Jones"
       and $seller/userid  = $item/offered_by
       and contains($item/description , "Bicycle")
       and $item/itemno  = $highbid/itemno
       and $highbid/userid  = $buyer/userid
       and $highbid/bid = max(
                               document("docs/bids.xml")//bid_tuple
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
%%%
<result>
   {
     for $item in document("items.xml")//item_tuple
     let $b := document("bids.xml")//bid_tuple[itemno = $item/itemno]
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
%%%
let $allbikes := document("items.xml")//item_tuple
                     [contains(description, "Bicycle")
                      or contains(description, "Tricycle")]
let $bikebids := document("bids.xml")//bid_tuple[itemno = $allbikes/itemno]
return
     <high_bid>
       {
         max($bikebids/bid)
       }
     </high_bid> 
%%%
let $item := document("items.xml")//item_tuple
   [end_date >= date("1999-03-01") and end_date <= date("1999-03-31")]
return
     <item_count>
       {
         count($item)
       }
     </item_count>
%%%
<result>
   {
     let $end_dates := document("items.xml")//item_tuple/end_date
     for $m in distinct-values(for $e in $end_dates
                               return get-month-from-date($e))
     let $item := document("items.xml")
         //item_tuple[get-year-from-date(end_date) = 1999
                      and get-month-from-date(end_date) = $m]
     order by $m
     return
         <monthly_result>
             <month>{ $m }</month>
             <item_count>{ count($item) }</item_count>
         </monthly_result>
   }
</result>
%%%
<result>
  {
     for $highbid in document("bids.xml")//bid_tuple,
         $user in document("users.xml")//user_tuple
     where $user/userid = $highbid/userid
       and $highbid/bid = 
max(document("bids.xml")//bid_tuple[itemno=$highbid/itemno]/bid)
     order by $highbid/itemno
     return
         <high_bid>
             { $highbid/itemno }
             { $highbid/bid }
             <bidder>{ $user/name/text() }</bidder>
         </high_bid>
   }
</result> 
%%%
let $highbid := max(document("bids.xml")//bid_tuple/bid)
return
     <result>
      {
         for $item in document("items.xml")//item_tuple,
             $b in document("bids.xml")//bid_tuple[itemno = $item/itemno]
         where $b/bid = $highbid
         return
             <expensive_item>
                 { $item/itemno }
                 { $item/description }
                 <high_bid>{ $highbid }</high_bid>
             </expensive_item>
      }
     </result> 
%%%
declare function bid_summary()
   as element()*
{
     for $i in distinct-values(document("bids.xml")//itemno)
     let $b := document("bids.xml")//bid_tuple[itemno = $i]
     return
         <bid_count>
             <itemno>{ $i }</itemno>
             <nbids>{ count($b) }</nbids>
         </bid_count>
};

<result>
  {
     let $bid_counts := bid_summary(),
         $maxbids := max($bid_counts/nbids),
         $maxitemnos := $bid_counts[nbids = $maxbids]
     for $item in document("items.xml")//item_tuple,
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
%%%
<result>
  {
     for $uid in distinct-values(document("bids.xml")//userid),
         $u in document("users.xml")//user_tuple[userid = $uid]
     let $b := document("bids.xml")//bid_tuple[userid = $uid]
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
%%%
<result>
  {
     for $i in distinct-values(document("bids.xml")//itemno)
     let $b := document("bids.xml")//bid_tuple[itemno = $i]
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
%%%
<result>
   {
     for $u in document("users.xml")//user_tuple
     let $b := document("bids.xml")//bid_tuple[userid=$u/userid and bid>=100]
     where count($b) > 1
     return
         <big_spender>{ $u/name/text() }</big_spender>
   }
</result>

%%%
<result>
   {
     for $u in document("users.xml")//user_tuple
     let $b := document("bids.xml")//bid_tuple[userid = $u/userid]
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

%%%
<frequent_bidder>
   {
     for $u in document("users.xml")//user_tuple
     where
       every $item in document("items.xml")//item_tuple satisfies
         some $b in document("bids.xml")//bid_tuple satisfies
           ($item/itemno = $b/itemno and $u/userid = $b/userid)
     return
         $u/name
   }
</frequent_bidder>
%%%
<result>
   {
     for $u in document("users.xml")//user_tuple
     order by $u/name
     return
         <user>
             { $u/name }
             {
                 for $b in distinct-values(document("bids.xml")//bid_tuple
                                              [userid = $u/userid]/itemno)
                 for $i in document("items.xml")//item_tuple[itemno = $b]
                 let $descr := $i/description/text()
                 order by $descr
                 return
                     <bid_on_item>{ $descr }</bid_on_item>
             }
         </user>
   }
</result>

%%%
<result>
   {
     input()//report//para
   }
</result>
%%%
<result>
   {
     input()//intro/para
   }
</result>
%%%
<result>
   {
     for $c in input()//chapter
     where empty($c/intro)
     return $c/section/intro/para
   }
</result> 
%%%
<result>
   {
     (((input()//chapter)[2]//section)[3]//para)[2]
   }
</result> 
%%%
<result>
   {
     input()//para[@security = "c"]
   }
</result> 
%%%
<result>
   {
     for $s in input()//section/@shorttitle
     return <stitle>{ $s }</stitle>
   }
</result> 
%%%
<result>
   {
     for $i in input()//intro/para[1]
     return
         <first_letter>{ substring(string($i), 1, 1) }</first_letter>
   }
</result> 
%%%
<result>
    {
      input()//section[.//title[contains(., "is SGML")]]
    }
</result> 
%%%
<result>
    {
      input()//section[.//title/text()[contains(., "is SGML")]]
    }
</result> 
%%%
<result>
   {
     for $id in input()//xref/@xrefid
     return input()//topic[@topicid = $id]
   }
</result> 
%%%
<result>
   {
     let $x := input()//xref[@xrefid = "top4"],
         $t := input()//title[. << $x]
     return $t[last()]
   }
</result> 
%%%
input()//news_item/title[contains(., "Foobar Corporation")] 

%%%
declare function partners($company as xs:string) as element()*
{
     let $c := document("company-data.xml")//company[name = $company]
     return $c//partner
};

let $foobar_partners := partners("Foobar Corporation")

for $item in input()//news_item
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
%%%
declare function partners($company as xs:string) as 
element()*
{
     let $c := document("company-data.xml")//company[name = $company]
     return $c//partner
};

for $item in input()//news_item,
     $c in document("company-data.xml")//company
let $partners := partners($c/name)
where contains(string($item), $c/name)
   and (some $p in $partners satisfies
     contains(string($item), $p) and $item/news_agent != $c/name)
return
     $item 
%%%
for $item in input()//news_item
where contains(string($item/content), "Gorilla Corporation")
return
     <item_summary>
         { $item/title/text() }.
         { $item/date/text() }.
         { string(($item//par)[1]) }
     </item_summary> 
%%%
<Q1>
   {
     for $n in distinct-values(
                   for $i in (input()//* | input()//@*)
                   return namespace-uri($i)
                )
     return  <ns>{$n}</ns>
   }
</Q1> 
%%%
declare namespace music = "http://www.example.org/music/records";

<Q2>
   {
     input()//music:title
   }
</Q2> 
%%%
declare namespace dt = "http://www.w3.org/2001/XMLSchema";

<Q3>
   {
     input()//*[@dt:*]
   }
</Q3> 
%%%
declare namespace xlink = "http://www.w3.org/1999/xlink";

<Q4>
   {
     for $hr in input()//@xlink:href
     return <ns>{ $hr }</ns>
   }
</Q4>
%%%
declare namespace music = "http://www.example.org/music/records";

<Q5>
   {
      input()//music:record[music:remark/@xml:lang = "de"]
   }
</Q5> 
%%%
declare namespace ma = "http://www.example.com/AuctionWatch";
declare namespace anyzone = "http://www.example.com/auctioneers#anyzone";

<Q6>
   {
     input()//ma:Auction[@anyzone:ID]/ma:Schedule/ma:Close
   }
</Q6>
%%%
declare namespace ma = "http://www.example.com/AuctionWatch";

<Q7>
   {
     for $a in input()//ma:Auction
     let $seller_id := $a/ma:Trading_Partners/ma:Seller/*:ID,
         $buyer_id := $a/ma:Trading_Partners/ma:High_Bidder/*:ID
     where namespace-uri($seller_id) = namespace-uri($buyer_id)
     return
         $a/ma:AuctionHomepage
   }
</Q7> 
%%%
declare namespace ma = "http://www.example.com/AuctionWatch";

<Q8>
   {
     for $s in input()//ma:Trading_Partners/(ma:Seller | ma:High_Bidder)
     where $s/*:NegativeComments = 0
     return $s
   }
</Q8>
%%%
declare function one_level ($p as element()) as element()
{
     <part partid="{ $p/@partid }"
           name="{ $p/@name }" >
         {
             for $s in document("partlist.xml")//part
             where $s/@partof = $p/@partid
             return one_level($s)
         }
     </part>
};

<parttree>
   {
     for $p in document("partlist.xml")//part[empty(@partof)]
     return one_level($p)
   }
</parttree>
%%%
import schema namespace ipo = "http://www.example.com/IPO";

count(
   document("ipo.xml")//shipTo[. instance of element(*, ipo:UKAddress)]
)

%%%
module namespace mylib = "http://www.example.com/xq/zips";
import schema namespace ipo = "http://www.example.com/IPO";
import schema namespace zips = "http://www.example.com/zips";

declare function zip-ok($a as element(*, ipo:USAddress))
   as xs:boolean
{
   some $i in document("zips.xml")/zips:zips/element(zips:row)
   satisfies $i/zips:city = $a/city
         and $i/zips:state = $a/state
         and $i/zips:zip = $a/zip
}; 
%%%
module namespace mylib = "http://www.example.com/xq/postals";
import schema namespace ipo = "http://www.example.com/IPO";
import schema namespace pst = "http://www.example.com/postals";

declare function postal-ok($a as element(*, ipo:UKAddress))
   as xs:boolean
{
   some $i in document("postals.xml")/pst:postals/element(pst:row)
   satisfies $i/pst:city = $a/city
        and xf:starts-with($a/postcode, $i/pst:prefix)
}; 
%%%
import schema namespace ipo="http://www.example.com/IPO";
import schema namespace pst="http://www.example.com/postals";
import schema namespace zips="http://www.example.com/zips";

import module namespace zok="http://www.example.com/xq/zips";
import module namespace pok="http://www.example.com/xq/postals";

declare function address-ok($a as element(*, ipo:Address))
  as xs:boolean
{
   typeswitch ($a)
       case $zip as element(*, ipo:USAddress)
            return zok:zip-ok($zip)
       case $postal as element(*, ipo:UKAddress )
            return pok:postal-ok($postal)
       default return false()
};

for $p in document("ipo.xml")//element(ipo:purchaseOrder)
where not( address-ok($p/shipTo) and address-ok($p/billTo))
return $p 

%%%
import schema namespace ipo="http://www.example.com/IPO";

declare function names-match( $s as element(shipTo),
                              $b as element(billTo) )
   as xs:boolean
{
      $s/name = $b/name
};

for $p in document("ipo.xml")//element(ipo:purchaseOrder)
where not( names-match( $p/shipTo, $p/billTo ) )
return $p                        
%%%
import schema namespace 
ipo="http://www.example.com/IPO";

for $p in document("ipo.xml")//element(ipo:purchaseOrder),
     $b in $p/billTo
where not( $b instance of element(*, ipo:USAddress))
   and exists( $p//USPrice )
return $p 

%%%
import schema namespace ipo="http://www.example.com/IPO";

declare function comment-text($c as element(ipo:comment))
   as xs:string
{
     xs:string( $c )
};

for $p in document("ipo.xml")//element(ipo:purchaseOrder),
     $t in comment-text( $p//ipo:shipComment )
where $p/shipTo/name="Helen Zoe"
     and $p/orderDate = xs:date("1999-12-01")
return $t 
%%%
for $p in document("ipo.xml")//element(ipo:purchaseOrder)
where $p/shipTo/name="Helen Zoe"
   and $p/@orderDate = xs:date("1999-12-01")
return comment-text( $p//ipo:customerComment ) 
%%%

import schema namespace ipo="http://www.example.com/IPO";

for $p in document("ipo.xml")//element(ipo:purchaseOrder)
where $p/shipTo/name="Helen Zoe"
   and $p/@orderDate = xs:date("1999-12-01")
return $p//element(ipo:comment)

%%%
module namespace mylib = "test";
import schema namespace ipo="http://www.example.com/IPO";

declare function comments-for-element( $e as element() )
   as ipo:comment*
{
   let $c := $e/element(ipo:comment)
   return $c
};   

%%%
module namespace mylib = "test";
import schema namespace ipo="http://www.example.com/IPO";

declare function deadbeat( $b as element(billTo, ipo:USAddress) )
   as xs:boolean
{
    $b/name = 
document("http://www.usa-deadbeats.com/current")/deadbeats/row/name
};


%%%
module namespace mylib = "http://www.example.com/calc";
import schema namespace ipo="http://www.example.com/IPO";

declare function total-price( $i as element(ipo:item)* )
   as xs:decimal
{
   let $subtotals := for $s in $i return $s/quantity * $s/USPrice
   return sum( $subtotals )
};

%%%
import schema namespace ipo="http://www.example.com/IPO";
import module namespace calc = "http://www.example.com/calc";

for $p in document("ipo.xml")//element(ipo:purchaseOrder)
where $p/shipTo/name="Helen Zoe"
    and $p/orderDate = xs:date("1999-12-01")
return calc:total-price($p//ipo:item) 

%%%

  for $z in (123, "123", <a/>, "456", 456, <b/>) return
    typeswitch ($z)
    case xs:string return "S"
    case xs:integer return "I"
    case element(a) return <e>Ea</e>
    case element(b) return element {QName-in-context("e",true())}{"Eb"}
    default return "D"

%%%

module namespace mylib = "http://www.example.com/test";
declare function sections-and-titles($n as node()) as node()?
   {
   if (local-name($n) = "section")
   then element
          { local-name($n) }
          { for $c in $n/* return sections-and-titles($c) }
   else if (local-name($n) = "title")
   then $n
   else ( )
   };
declare function swizzle($n as node()) as node()
   {
   if ($n instance of attribute and local-name($n) = "color")
   then element color { string($n) }
   else if ($n instance of element and local-name($n) = "size")
   then attribute size { string($n) }
   else if ($n instance of element)
   then element
          { local-name($n) }
          { for $c in $n/node() return swizzle($c) }
   else $n
   };

%%%

typeswitch($n)
     case $a as attribute(color)
       return element color { string($a) } 
     case $es as element(size) 
       return attribute size { string($es) } 
     case $e as element() 
       return element 
         { local-name($e) } 
         { for $c in $e/(* | @*) return swizzle($c) } 
     case $d as document-node() 
       return document 
         { for $c in $d/* return swizzle($c) } 
     default return $n 


%%%

   (element 
         { local-name($e) } 
         { for $c in $e/(* | @*) 
           return foo:yada 
         },
     element 
         { local-name($e) } 
         { attribute abc {'test1'},
           attribute {document('abc')/doc/@attr} {'test1'},
           for $c in $e/(* | @*) 
           return foo:yada 
         })

%%%

declare base-uri "abc";
foo

%%%

document-node(element(xxx))

%%%

document(element(baz, yada?))

%%%

processing-instruction(foo)

%%%

processing-instruction("foo yada yada")

%%%

(processing-instruction aname {foo},
processing-instruction {name-source} {foo},
comment {foo})

%%%

declare boundary-space strip;
2+2

%%%

declare boundary-space preserve;
2+2

%%%

declare copy-namespaces preserve, inherit;
2+2

%%%

declare copy-namespaces no-preserve, inherit;
2+2

%%%

declare copy-namespaces preserve, no-inherit;
2+2

%%%

declare copy-namespaces no-preserve, no-inherit;
2+2

%%%

  import schema namespace bib="urn:examples:xmp:bib";

  validate
   {
    <bib:price>49.99</bib:price>
   }

%%%

  import schema namespace bib="urn:examples:xmp:bib";

  validate
   {
    <bib:price>49.99</bib:price>
   }

%%%

validate strict {$x}

%%%

import schema namespace bib="urn:examples:xmp:bib";
 
validate
{
     <bib:price>49.99</bib:price>
}

%%%

import schema namespace bib="urn:examples:xmp:bib";
 
validate
{
    <bib:price>49.99</bib:price>
}


%%%


element foo:bar {
     attribute a1 {"foo"},
     element e1 {"goo"}
}

%%%

let $b := 1.0 return typeswitch ( <a>1</a> < $b ) case $a as xs:int return 1 default return 'unknown'
%%%
<?foo abcd  ?>
%%%
<?foo?>
%%%
<?foo ?>
%%%
<?foo    x dx dsd dd    ?>
%%%
<elem>
{
typeswitch ($a div 3)
    case $a as xs:integer return "integer"
    default return "no integer"
}
</elem>
%%%
<!--- - blah - - --> | e
%%%
<?PITarget ?> | e
%%%
<Q> { typeswitch (e) case e return e default return e } </Q>
%%%
processing-instruction {x} {x}
%%%
declare variable $x as processing-instruction()? external; e
%%%
declare variable $x  external; e
%%%
declare function Q() external; e

%%%
declare ordering unordered;

ordered { foo } + 2

%%%
declare ordering ordered;

unordered { foo } + 2
%%%
<result>
{
		 element  {"name"} {"value"}
}
</result>
%%%
(: Name: Literals067 :)
(: Description: Test the escaping of the ' (apostrophe) and " (quotation) characters as part of an XML attribute constructor. Notice that the &quot; (quote) characters need to be entitized in the attribute content for XML validity :)

(: insert-start :)
declare variable $input-context external;
(: insert-end :)

<test check='He said, "I don''t like it."' />
%%%
(: Name: combiningnodeseqhc5 :)
(: Description: Simple combination of node sequences involving integers and the empty sequence.  Uses "|" operator:)

(: insert-start :)
declare variable $input-context1 external;
(: insert-end :)

() | ($input-context1//hours)
%%%
xquery div xquery < <xquery xquery="xquery">{xquery}</xquery>
%%%
version div version < <version version="version">{version}</version>
%%%
encoding div encoding < <encoding encoding="encoding">{encoding}</encoding>
%%%
module div module < <module module="module">{module}</module>
%%%
namespace div namespace < <namespace namespace="namespace">{namespace}</namespace>
%%%
declare div declare < <declare declare="declare">{declare}</declare>
%%%
boundary-space div boundary-space < <boundary-space boundary-space="boundary-space">{boundary-space}</boundary-space>
%%%
preserve div preserve < <preserve preserve="preserve">{preserve}</preserve>
%%%
strip div strip < <strip strip="strip">{strip}</strip>
%%%
default div default < <default default="default">{default}</default>
%%%
element div element < <element element="element">{element}</element>
%%%
function div function < <function function="function">{function}</function>
%%%
option div option < <option option="option">{option}</option>
%%%
ft-option div ft-option < <ft-option ft-option="ft-option">{ft-option}</ft-option>
%%%
ordering div ordering < <ordering ordering="ordering">{ordering}</ordering>
%%%
ordered div ordered < <ordered ordered="ordered">{ordered}</ordered>
%%%
unordered div unordered < <unordered unordered="unordered">{unordered}</unordered>
%%%
order div order < <order order="order">{order}</order>
%%%
empty div empty < <empty empty="empty">{empty}</empty>
%%%
greatest div greatest < <greatest greatest="greatest">{greatest}</greatest>
%%%
least div least < <least least="least">{least}</least>
%%%
copy-namespaces div copy-namespaces < <copy-namespaces copy-namespaces="copy-namespaces">{copy-namespaces}</copy-namespaces>
%%%
no-preserve div no-preserve < <no-preserve no-preserve="no-preserve">{no-preserve}</no-preserve>
%%%
inherit div inherit < <inherit inherit="inherit">{inherit}</inherit>
%%%
no-inherit div no-inherit < <no-inherit no-inherit="no-inherit">{no-inherit}</no-inherit>
%%%
collation div collation < <collation collation="collation">{collation}</collation>
%%%
base-uri div base-uri < <base-uri base-uri="base-uri">{base-uri}</base-uri>
%%%
import div import < <import import="import">{import}</import>
%%%
schema div schema < <schema schema="schema">{schema}</schema>
%%%
at div at < <at at="at">{at}</at>
%%%
variable div variable < <variable variable="variable">{variable}</variable>
%%%
external div external < <external external="external">{external}</external>
%%%
construction div construction < <construction construction="construction">{construction}</construction>
%%%
updating div updating < <updating updating="updating">{updating}</updating>
%%%
as div as < <as as="as">{as}</as>
%%%
return div return < <return return="return">{return}</return>
%%%
do div do < <do do="do">{do}</do>
%%%
for div for < <for for="for">{for}</for>
%%%
in div in < <in in="in">{in}</in>
%%%
score div score < <score score="score">{score}</score>
%%%
let div let < <let let="let">{let}</let>
%%%
where div where < <where where="where">{where}</where>
%%%
by div by < <by by="by">{by}</by>
%%%
stable div stable < <stable stable="stable">{stable}</stable>
%%%
ascending div ascending < <ascending ascending="ascending">{ascending}</ascending>
%%%
descending div descending < <descending descending="descending">{descending}</descending>
%%%
some div some < <some some="some">{some}</some>
%%%
every div every < <every every="every">{every}</every>
%%%
satisfies div satisfies < <satisfies satisfies="satisfies">{satisfies}</satisfies>
%%%
typeswitch div typeswitch < <typeswitch typeswitch="typeswitch">{typeswitch}</typeswitch>
%%%
case div case < <case case="case">{case}</case>
%%%
if div if < <if if="if">{if}</if>
%%%
then div then < <then then="then">{then}</then>
%%%
else div else < <else else="else">{else}</else>
%%%
or or or < <or or="or">{or}</or>
%%%
and and and < <and and="and">{and}</and>
%%%
ftcontains div ftcontains < <ftcontains ftcontains="ftcontains">{ftcontains}</ftcontains>
%%%
to to to < <to to="to">{to}</to>
%%%
div div div < <div div="div">{div}</div>
%%%
idiv idiv idiv < <idiv idiv="idiv">{idiv}</idiv>
%%%
mod mod mod < <mod mod="mod">{mod}</mod>
%%%
union union union < <union union="union">{union}</union>
%%%
intersect intersect intersect < <intersect intersect="intersect">{intersect}</intersect>
%%%
except except except < <except except="except">{except}</except>
%%%
instance div instance < <instance instance="instance">{instance}</instance>
%%%
of div of < <of of="of">{of}</of>
%%%
treat div treat < <treat treat="treat">{treat}</treat>
%%%
castable div castable < <castable castable="castable">{castable}</castable>
%%%
cast div cast < <cast cast="cast">{cast}</cast>
%%%
(eq eq eq) < <eq eq="eq">{eq}</eq>
%%%
(ne ne ne) < <ne ne="ne">{ne}</ne>
%%%
(lt lt lt) < <lt lt="lt">{lt}</lt>
%%%
(le le le) < <le le="le">{le}</le>
%%%
(gt gt gt) < <gt gt="gt">{gt}</gt>
%%%
(ge ge ge) < <ge ge="ge">{ge}</ge>
%%%
(is is is) < <is is="is">{is}</is>
%%%
validate div validate < <validate validate="validate">{validate}</validate>
%%%
lax div lax < <lax lax="lax">{lax}</lax>
%%%
strict div strict < <strict strict="strict">{strict}</strict>
%%%
child div child < <child child="child">{child}</child>
%%%
descendant div descendant < <descendant descendant="descendant">{descendant}</descendant>
%%%
attribute div attribute < <attribute attribute="attribute">{attribute}</attribute>
%%%
self div self < <self self="self">{self}</self>
%%%
descendant-or-self div descendant-or-self < <descendant-or-self descendant-or-self="descendant-or-self">{descendant-or-self}</descendant-or-self>
%%%
following-sibling div following-sibling < <following-sibling following-sibling="following-sibling">{following-sibling}</following-sibling>
%%%
following div following < <following following="following">{following}</following>
%%%
parent div parent < <parent parent="parent">{parent}</parent>
%%%
ancestor div ancestor < <ancestor ancestor="ancestor">{ancestor}</ancestor>
%%%
preceding-sibling div preceding-sibling < <preceding-sibling preceding-sibling="preceding-sibling">{preceding-sibling}</preceding-sibling>
%%%
preceding div preceding < <preceding preceding="preceding">{preceding}</preceding>
%%%
ancestor-or-self div ancestor-or-self < <ancestor-or-self ancestor-or-self="ancestor-or-self">{ancestor-or-self}</ancestor-or-self>
%%%
document div document < <document document="document">{document}</document>
%%%
text div text < <text text="text">{text}</text>
%%%
comment div comment < <comment comment="comment">{comment}</comment>
%%%
processing-instruction div processing-instruction < <processing-instruction processing-instruction="processing-instruction">{processing-instruction}</processing-instruction>
%%%
empty-sequence div empty-sequence < <empty-sequence empty-sequence="empty-sequence">{empty-sequence}</empty-sequence>
%%%
item div item < <item item="item">{item}</item>
%%%
node div node < <node node="node">{node}</node>
%%%
document-node div document-node < <document-node document-node="document-node">{document-node}</document-node>
%%%
schema-attribute div schema-attribute < <schema-attribute schema-attribute="schema-attribute">{schema-attribute}</schema-attribute>
%%%
schema-element div schema-element < <schema-element schema-element="schema-element">{schema-element}</schema-element>
%%%
id div id < <id id="id">{id}</id>
%%%
key div key < <key key="key">{key}</key>
%%%
weight div weight < <weight weight="weight">{weight}</weight>
%%%
not div not < <not not="not">{not}</not>
%%%
lowercase div lowercase < <lowercase lowercase="lowercase">{lowercase}</lowercase>
%%%
uppercase div uppercase < <uppercase uppercase="uppercase">{uppercase}</uppercase>
%%%
sensitive div sensitive < <sensitive sensitive="sensitive">{sensitive}</sensitive>
%%%
insensitive div insensitive < <insensitive insensitive="insensitive">{insensitive}</insensitive>
%%%
with div with < <with with="with">{with}</with>
%%%
diacritics div diacritics < <diacritics diacritics="diacritics">{diacritics}</diacritics>
%%%
without div without < <without without="without">{without}</without>
%%%
stemming div stemming < <stemming stemming="stemming">{stemming}</stemming>
%%%
thesaurus div thesaurus < <thesaurus thesaurus="thesaurus">{thesaurus}</thesaurus>
%%%
relationship div relationship < <relationship relationship="relationship">{relationship}</relationship>
%%%
levels div levels < <levels levels="levels">{levels}</levels>
%%%
stop div stop < <stop stop="stop">{stop}</stop>
%%%
words div words < <words words="words">{words}</words>
%%%
language div language < <language language="language">{language}</language>
%%%
wildcards div wildcards < <wildcards wildcards="wildcards">{wildcards}</wildcards>
%%%
start div start < <start start="start">{start}</start>
%%%
end div end < <end end="end">{end}</end>
%%%
entire div entire < <entire entire="entire">{entire}</entire>
%%%
content div content < <content content="content">{content}</content>
%%%
any div any < <any any="any">{any}</any>
%%%
word div word < <word word="word">{word}</word>
%%%
all div all < <all all="all">{all}</all>
%%%
phrase div phrase < <phrase phrase="phrase">{phrase}</phrase>
%%%
exactly div exactly < <exactly exactly="exactly">{exactly}</exactly>
%%%
most div most < <most most="most">{most}</most>
%%%
from div from < <from from="from">{from}</from>
%%%
distance div distance < <distance distance="distance">{distance}</distance>
%%%
window div window < <window window="window">{window}</window>
%%%
occurs div occurs < <occurs occurs="occurs">{occurs}</occurs>
%%%
times div times < <times times="times">{times}</times>
%%%
same div same < <same same="same">{same}</same>
%%%
different div different < <different different="different">{different}</different>
%%%
sentences div sentences < <sentences sentences="sentences">{sentences}</sentences>
%%%
paragraphs div paragraphs < <paragraphs paragraphs="paragraphs">{paragraphs}</paragraphs>
%%%
sentence div sentence < <sentence sentence="sentence">{sentence}</sentence>
%%%
paragraph div paragraph < <paragraph paragraph="paragraph">{paragraph}</paragraph>
%%%
insert div insert < <insert insert="insert">{insert}</insert>
%%%
first div first < <first first="first">{first}</first>
%%%
last div last < <last last="last">{last}</last>
%%%
into div into < <into into="into">{into}</into>
%%%
after div after < <after after="after">{after}</after>
%%%
before div before < <before before="before">{before}</before>
%%%
delete div delete < <delete delete="delete">{delete}</delete>
%%%
replace div replace < <replace replace="replace">{replace}</replace>
%%%
value div value < <value value="value">{value}</value>
%%%
rename div rename < <rename rename="rename">{rename}</rename>
%%%
transform div transform < <transform transform="transform">{transform}</transform>
%%%
update div update < <update update="update">{update}</update>
%%%
copy div copy < <copy copy="copy">{copy}</copy>
%%%
modify div modify < <modify modify="modify">{modify}</modify>
%%%
type div type < <type type="type">{type}</type>
%%%
function()
