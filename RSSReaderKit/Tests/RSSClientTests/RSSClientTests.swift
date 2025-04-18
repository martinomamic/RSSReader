//
//  RSSClientTests.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 12.04.25.
//

import Testing
import Foundation
@testable import RSSClient
@testable import SharedModels

@Suite struct RSSParserTests {
    @Test("Parse valid RSS feed")
    func testParseValidRSSFeed() async throws {
        let parser = RSSParser()
        let sampleRSSData = bbcXML.data(using: .utf8)!
        let url = URL(string: "https://example.com/feed.xml")!

        let (feed, items) = try await parser.parse(data: sampleRSSData, feedURL: url)

        #expect(feed?.title == "BBC News")
        #expect(feed?.description == "BBC News - World")
        #expect(feed?.url == url)
        #expect(items.count == 24)

        let firstItem = items.first
        #expect(firstItem != nil)
        #expect(firstItem?.title == "Israeli air strike destroys part of last functioning hospital in Gaza City")
        #expect(firstItem?.description == "The Israel Defense Forces said the hospital contained a \"command and control center used by Hamas\".")
        #expect(firstItem?.link == URL(string: "https://www.bbc.com/news/articles/cjr7l123zy5o"))
    }

    @Test("Parse invalid XML throws error")
    func testParseInvalidXML() async throws {
        let parser = RSSParser()
        let invalidXMLData = "blob".data(using: .utf8)!
        let url = URL(string: "blob")!

        do {
            _ = try await parser.parse(data: invalidXMLData, feedURL: url)
            #expect(Bool(false), "Invalid XML error")
        } catch {
            #expect(error is RSSError)
        }
    }
}

private let bbcXML = """
<rss xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:media="http://search.yahoo.com/mrss/" version="2.0">
<script id="pphgdbgldlmicfdkhondlafkiomnelnk"/>
<script/>
<script/>
<channel>
<title>
<![CDATA[ BBC News ]]>
</title>
<description>
<![CDATA[ BBC News - World ]]>
</description>
<link>https://www.bbc.co.uk/news/world</link>
<image>
<url>https://news.bbcimg.co.uk/nol/shared/img/bbc_news_120x60.gif</url>
<title>BBC News</title>
<link>https://www.bbc.co.uk/news/world</link>
</image>
<generator>RSS for Node</generator>
<lastBuildDate>Sun, 13 Apr 2025 08:41:11 GMT</lastBuildDate>
<atom:link href="https://feeds.bbci.co.uk/news/world/rss.xml" rel="self" type="application/rss+xml"/>
<copyright>
<![CDATA[ Copyright: (C) British Broadcasting Corporation, see https://www.bbc.co.uk/usingthebbc/terms-of-use/#15metadataandrssfeeds for terms and conditions of reuse. ]]>
</copyright>
<language>
<![CDATA[ en-gb ]]>
</language>
<ttl>15</ttl>
<item>
<title>
<![CDATA[ Israeli air strike destroys part of last functioning hospital in Gaza City ]]>
</title>
<description>
<![CDATA[ The Israel Defense Forces said the hospital contained a "command and control center used by Hamas". ]]>
</description>
<link>https://www.bbc.com/news/articles/cjr7l123zy5o</link>
<guid isPermaLink="false">https://www.bbc.com/news/articles/cjr7l123zy5o#0</guid>
<pubDate>Sun, 13 Apr 2025 08:27:48 GMT</pubDate>
<media:thumbnail width="240" height="135" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/7630/live/f606dca0-183a-11f0-b552-23f7caa5b442.jpg"/>
</item>
<item>
<title>
<![CDATA[ Trump exempts smartphones and computers from new tariffs ]]>
</title>
<description>
<![CDATA[ It follows concerns that tech prices could skyrocket, as many gadgets are made in China, with the US president saying he will give more detail on Monday. ]]>
</description>
<link>https://www.bbc.com/news/articles/c20xn626y81o</link>
<guid isPermaLink="false">https://www.bbc.com/news/articles/c20xn626y81o#0</guid>
<pubDate>Sun, 13 Apr 2025 02:17:37 GMT</pubDate>
<media:thumbnail width="240" height="135" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/478d/live/22a84d60-17b5-11f0-9591-1de60ef65af2.jpg"/>
</item>
<item>
<title>
<![CDATA[ Man mistakenly deported to El Salvador 'alive and secure', US says ]]>
</title>
<description>
<![CDATA[ A judge has called for the Trump administration to facilitate the return of Kilmar Abrego Garcia to the US. ]]>
</description>
<link>https://www.bbc.com/news/articles/c9qwxwrr74jo</link>
<guid isPermaLink="false">https://www.bbc.com/news/articles/c9qwxwrr74jo#0</guid>
<pubDate>Sun, 13 Apr 2025 00:12:16 GMT</pubDate>
<media:thumbnail width="240" height="135" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/a446/live/a1b0d640-17f6-11f0-a8d5-a3a652ec5dc2.jpg"/>
</item>
<item>
<title>
<![CDATA[ US and Iran hold 'constructive' first round of nuclear talks ]]>
</title>
<description>
<![CDATA[ The highest-level talks between the two nations since Trump's first term in office will resume next week. ]]>
</description>
<link>https://www.bbc.com/news/articles/c4g2eggzvjgo</link>
<guid isPermaLink="false">https://www.bbc.com/news/articles/c4g2eggzvjgo#0</guid>
<pubDate>Sat, 12 Apr 2025 18:31:12 GMT</pubDate>
<media:thumbnail width="240" height="134" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/c453/live/464736f0-17bf-11f0-a710-e18c9fa98fc5.jpg"/>
</item>
<item>
<title>
<![CDATA[ 'Russians are even trying to ban our holidays' - life in occupied Ukraine ]]>
</title>
<description>
<![CDATA[ Ukrainians in Russian-held land tell the BBC about the difficulties of life under occupation. ]]>
</description>
<link>https://www.bbc.com/news/articles/c93gy91y43vo</link>
<guid isPermaLink="false">https://www.bbc.com/news/articles/c93gy91y43vo#0</guid>
<pubDate>Sat, 12 Apr 2025 23:02:16 GMT</pubDate>
<media:thumbnail width="240" height="135" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/a0ed/live/dae74290-16c6-11f0-963a-3738e7f2791c.jpg"/>
</item>
<item>
<title>
<![CDATA[ Thousands attend pro-government rally in Serbia after months of unrest ]]>
</title>
<description>
<![CDATA[ An estimated 50,000 people were there - significantly fewer than the 325,000 at last month's anti-government protest. ]]>
</description>
<link>https://www.bbc.com/news/articles/cly18qd7x7do</link>
<guid isPermaLink="false">https://www.bbc.com/news/articles/cly18qd7x7do#0</guid>
<pubDate>Sun, 13 Apr 2025 02:06:33 GMT</pubDate>
<media:thumbnail width="240" height="134" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/cba1/live/a5ef7f70-17f8-11f0-9cfa-efa3aa44fbfd.png"/>
</item>
<item>
<title>
<![CDATA[ Rourke leaves Big Brother after 'unacceptable behaviour' ]]>
</title>
<description>
<![CDATA[ The Hollywood actor was formally warned by the show earlier this week over "offensive" language he had used. ]]>
</description>
<link>https://www.bbc.com/news/articles/cwynegdv09eo</link>
<guid isPermaLink="false">https://www.bbc.com/news/articles/cwynegdv09eo#0</guid>
<pubDate>Sat, 12 Apr 2025 22:10:54 GMT</pubDate>
<media:thumbnail width="240" height="135" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/a026/live/33224940-17e5-11f0-8a1e-3ff815141b98.jpg"/>
</item>
<item>
<title>
<![CDATA[ Three million child deaths linked to drug resistance, study shows ]]>
</title>
<description>
<![CDATA[ Children in Africa and South East Asia are most at risk from antibiotics medicines no longer working, a study suggests. ]]>
</description>
<link>https://www.bbc.com/news/articles/cy0xk86l9g9o</link>
<guid isPermaLink="false">https://www.bbc.com/news/articles/cy0xk86l9g9o#1</guid>
<pubDate>Sat, 12 Apr 2025 23:24:22 GMT</pubDate>
<media:thumbnail width="240" height="135" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/e6e5/live/2ceb9b20-16e7-11f0-9b40-fbe9d39f3ec7.jpg"/>
</item>
<item>
<title>
<![CDATA[ Tanzania's main opposition party banned from election ]]>
</title>
<description>
<![CDATA[ The move comes days after its leader and presidential candidate was arrested and charged with treason. ]]>
</description>
<link>https://www.bbc.com/news/articles/c793qd2x7yzo</link>
<guid isPermaLink="false">https://www.bbc.com/news/articles/c793qd2x7yzo#1</guid>
<pubDate>Sat, 12 Apr 2025 21:40:40 GMT</pubDate>
<media:thumbnail width="240" height="135" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/8446/live/41f37c20-17de-11f0-b3f8-05aa545a8d33.jpg"/>
</item>
<item>
<title>
<![CDATA[ Nigerian bandit kingpin and 100 followers killed ]]>
</title>
<description>
<![CDATA[ The crime lord was hiding in a forest, authorities say, after dozens were kidnapped from a village. ]]>
</description>
<link>https://www.bbc.com/news/articles/c15vwgjp0pqo</link>
<guid isPermaLink="false">https://www.bbc.com/news/articles/c15vwgjp0pqo#1</guid>
<pubDate>Sat, 12 Apr 2025 14:12:26 GMT</pubDate>
<media:thumbnail width="240" height="135" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/89f3/live/f673cf80-179b-11f0-8e92-794cc8da8125.jpg"/>
</item>
<item>
<title>
<![CDATA[ Hundreds of flights cancelled in China as strong winds hit capital ]]>
</title>
<description>
<![CDATA[ State media outlets earlier warned that people weighing less than 50kg may be "easily blown away". ]]>
</description>
<link>https://www.bbc.com/news/articles/c89gp9g5zyjo</link>
<guid isPermaLink="false">https://www.bbc.com/news/articles/c89gp9g5zyjo#1</guid>
<pubDate>Sat, 12 Apr 2025 13:47:28 GMT</pubDate>
<media:thumbnail width="240" height="135" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/4d03/live/96da9900-17a0-11f0-a455-cf1d5f751d2f.jpg"/>
</item>
<item>
<title>
<![CDATA[ US special envoy meets Putin as Trump urges Russia to 'get moving' on Ukraine ceasefire ]]>
</title>
<description>
<![CDATA[ Steve Witkoff held talks with the Russian president, meanwhile Moscow's ambassador to the UK told the BBC the US is not Russia's ally. ]]>
</description>
<link>https://www.bbc.com/news/articles/crm3kxxx8x9o</link>
<guid isPermaLink="false">https://www.bbc.com/news/articles/crm3kxxx8x9o#1</guid>
<pubDate>Sat, 12 Apr 2025 19:24:06 GMT</pubDate>
<media:thumbnail width="240" height="135" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/79bf/live/297dd9b0-16e9-11f0-b644-13c0d1d79f75.jpg"/>
</item>
<item>
<title>
<![CDATA[ Trump to end protected status for Afghans and Cameroonians ]]>
</title>
<description>
<![CDATA[ Homeland Security Secretary Kristi Noem found the conditions in both countries no longer merited US protections, a statement says. ]]>
</description>
<link>https://www.bbc.com/news/articles/cgeng08qe7zo</link>
<guid isPermaLink="false">https://www.bbc.com/news/articles/cgeng08qe7zo#1</guid>
<pubDate>Sat, 12 Apr 2025 01:23:53 GMT</pubDate>
<media:thumbnail width="240" height="135" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/129f/live/77baf1d0-179d-11f0-8a1e-3ff815141b98.jpg"/>
</item>
<item>
<title>
<![CDATA[ Coup leader seeks win in first vote since Gabon army takeover ]]>
</title>
<description>
<![CDATA[ About one million voters are set to pick their next president from a list of eight hopefuls. ]]>
</description>
<link>https://www.bbc.com/news/articles/cn91j20r8vxo</link>
<guid isPermaLink="false">https://www.bbc.com/news/articles/cn91j20r8vxo#1</guid>
<pubDate>Sat, 12 Apr 2025 03:32:35 GMT</pubDate>
<media:thumbnail width="240" height="134" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/d193/live/139c3cd0-16ea-11f0-8a1e-3ff815141b98.jpg"/>
</item>
<item>
<title>
<![CDATA[ Menendez brothers' bid for freedom can continue, judge rules ]]>
</title>
<description>
<![CDATA[ The ruling potentially paves the way for an early release for Erik and Lyle Menendez, who are serving life sentences for killing their parents. ]]>
</description>
<link>https://www.bbc.com/news/articles/cp8kmrg1p8go</link>
<guid isPermaLink="false">https://www.bbc.com/news/articles/cp8kmrg1p8go#1</guid>
<pubDate>Sat, 12 Apr 2025 00:57:12 GMT</pubDate>
<media:thumbnail width="240" height="135" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/ea13/live/f5ca4e00-15b7-11f0-a658-83a7b9f03655.jpg"/>
</item>
<item>
<title>
<![CDATA[ Will Saturday Night Live spin-off make Britain laugh? ]]>
</title>
<description>
<![CDATA[ A planned UK version of the legendary US comedy show is described as a "difficult proposition". ]]>
</description>
<link>https://www.bbc.com/news/articles/c3dk4r5j487o</link>
<guid isPermaLink="false">https://www.bbc.com/news/articles/c3dk4r5j487o#2</guid>
<pubDate>Sun, 13 Apr 2025 00:09:12 GMT</pubDate>
<media:thumbnail width="240" height="135" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/625f/live/c73ee7a0-17ea-11f0-8a1e-3ff815141b98.jpg"/>
</item>
<item>
<title>
<![CDATA[ Indian pot belly: From status symbol to silent killer ]]>
</title>
<description>
<![CDATA[ India’s obesity crisis is surging - and the humble pot belly may be a bigger villain than it seems. ]]>
</description>
<link>https://www.bbc.com/news/articles/czjnd4rzmglo</link>
<guid isPermaLink="false">https://www.bbc.com/news/articles/czjnd4rzmglo#2</guid>
<pubDate>Sun, 13 Apr 2025 00:36:47 GMT</pubDate>
<media:thumbnail width="240" height="134" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/50ed/live/6db0de70-1437-11f0-ac9f-c37d6fd89579.jpg"/>
</item>
<item>
<title>
<![CDATA[ The Last of Us: Bella Ramsey talks season 2, autism, and growing up on screen ]]>
</title>
<description>
<![CDATA[ The actor speaks about growing up in the spotlight and embracing her autism diagnosis. ]]>
</description>
<link>https://www.bbc.com/news/articles/c4g86w40er1o</link>
<guid isPermaLink="false">https://www.bbc.com/news/articles/c4g86w40er1o#2</guid>
<pubDate>Sun, 13 Apr 2025 00:08:25 GMT</pubDate>
<media:thumbnail width="240" height="135" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/167f/live/eec9fd30-16fc-11f0-a79b-a5d514d498b0.jpg"/>
</item>
<item>
<title>
<![CDATA[ As an Israeli hostage turns 48, his wife waits for blue ticks on her messages ]]>
</title>
<description>
<![CDATA[ Eighteen months since Omri Miran was taken hostage by Hamas, his wife Lishay still sends family updates, which she hopes he will read one day. ]]>
</description>
<link>https://www.bbc.com/news/articles/c4g86jy6jggo</link>
<guid isPermaLink="false">https://www.bbc.com/news/articles/c4g86jy6jggo#2</guid>
<pubDate>Fri, 11 Apr 2025 23:16:35 GMT</pubDate>
<media:thumbnail width="240" height="135" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/3b51/live/8bca2f00-16f4-11f0-b644-13c0d1d79f75.jpg"/>
</item>
<item>
<title>
<![CDATA[ Menendez brothers 'have exemplified growth and healing,' cousin says ]]>
</title>
<description>
<![CDATA[ The resentencing hearing of Menendez brothers can move forward despite opposition from the district attorney, a Los Angeles court has ruled. ]]>
</description>
<link>https://www.bbc.com/news/videos/cde2zyj2kg8o</link>
<guid isPermaLink="false">https://www.bbc.com/news/videos/cde2zyj2kg8o#3</guid>
<pubDate>Sat, 12 Apr 2025 12:09:09 GMT</pubDate>
<media:thumbnail width="240" height="135" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/21ad/live/480e5f00-1796-11f0-8a1e-3ff815141b98.jpg"/>
</item>
<item>
<title>
<![CDATA[ Watch: Was Trump's 90-day tariffs pause really a grand plan? ]]>
</title>
<description>
<![CDATA[ News of the US president's plan to halt higher-band taxes came as a surprise on Wednesday, but was it part of a plan? ]]>
</description>
<link>https://www.bbc.com/news/videos/c045el20yw1o</link>
<guid isPermaLink="false">https://www.bbc.com/news/videos/c045el20yw1o#3</guid>
<pubDate>Thu, 10 Apr 2025 22:49:21 GMT</pubDate>
<media:thumbnail width="240" height="135" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/cb53/live/f9d96cc0-16ab-11f0-a455-cf1d5f751d2f.jpg"/>
</item>
<item>
<title>
<![CDATA[ 'The helicopter just fell' - Hudson River crash leaves six dead ]]>
</title>
<description>
<![CDATA[ New York City Mayor Eric Adams confirmed all six people on board the flight were visiting from Spain. ]]>
</description>
<link>https://www.bbc.com/news/videos/czrv834e233o</link>
<guid isPermaLink="false">https://www.bbc.com/news/videos/czrv834e233o#3</guid>
<pubDate>Fri, 11 Apr 2025 00:16:17 GMT</pubDate>
<media:thumbnail width="240" height="135" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/0d85/live/996182c0-1673-11f0-b1b3-7358f8d35a35.jpg"/>
</item>
<item>
<title>
<![CDATA[ Watch: Pope seen without usual papal attire ]]>
</title>
<description>
<![CDATA[ Pope Francis visits St Peter's Basilica in the Vatican, still with an oxygen tube, as he continues to recover from ill health. ]]>
</description>
<link>https://www.bbc.com/news/videos/cz01100gz1jo</link>
<guid isPermaLink="false">https://www.bbc.com/news/videos/cz01100gz1jo#3</guid>
<pubDate>Thu, 10 Apr 2025 18:05:53 GMT</pubDate>
<media:thumbnail width="240" height="135" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/6204/live/d39a2350-1634-11f0-b1b3-7358f8d35a35.jpg"/>
</item>
<item>
<title>
<![CDATA[ Watch: Why US markets skyrocketed after Trump tariffs pause ]]>
</title>
<description>
<![CDATA[ The S&P 500 index soared 9.5% in the biggest one-day rally since 2008, following days of turmoil sparked by the tariffs. ]]>
</description>
<link>https://www.bbc.com/news/videos/cvgnnw15z83o</link>
<guid isPermaLink="false">https://www.bbc.com/news/videos/cvgnnw15z83o#3</guid>
<pubDate>Wed, 09 Apr 2025 21:35:55 GMT</pubDate>
<media:thumbnail width="240" height="135" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/36b8/live/4f04b710-1588-11f0-8a1e-3ff815141b98.jpg"/>
</item>
</channel>
</rss>
"""
