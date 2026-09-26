import json
import zipfile
from pathlib import Path
from xml.etree import ElementTree as ET


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "content" / "presentation" / "questions.json"
OUTPUT = ROOT / "content" / "presentation" / "ancient-greece-questions.pptx"

NS = {
    "a": "http://schemas.openxmlformats.org/drawingml/2006/main",
    "p": "http://schemas.openxmlformats.org/presentationml/2006/main",
    "r": "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
    "rel": "http://schemas.openxmlformats.org/package/2006/relationships",
    "ct": "http://schemas.openxmlformats.org/package/2006/content-types",
}
for prefix, uri in NS.items():
    if prefix in {"a", "p", "r"}:
        ET.register_namespace(prefix, uri)

EMU = 914400
WIDTH = 13.333333 * EMU
HEIGHT = 7.5 * EMU
INK = "12212A"
PANEL = "1C3038"
PAPER = "F7F3EA"
MUTED = "B7C7C6"
TEAL = "45D0B0"
GOLD = "F5BD63"
ACCENTS = [TEAL, GOLD, "78B9E8", "E99178"]


def qname(prefix, name):
    return f"{{{NS[prefix]}}}{name}"


def sub(parent, prefix, name, attrs=None):
    return ET.SubElement(parent, qname(prefix, name), attrs or {})


def inches(value):
    return str(round(value * EMU))


def add_transform(parent, x, y, width, height):
    transform = sub(parent, "a", "xfrm")
    sub(transform, "a", "off", {"x": inches(x), "y": inches(y)})
    sub(transform, "a", "ext", {"cx": inches(width), "cy": inches(height)})


def add_shape(tree, shape_id, x, y, width, height, fill, rounded=False):
    shape = sub(tree, "p", "sp")
    nv = sub(shape, "p", "nvSpPr")
    sub(nv, "p", "cNvPr", {"id": str(shape_id), "name": f"Shape {shape_id}"})
    sub(nv, "p", "cNvSpPr")
    sub(nv, "p", "nvPr")
    properties = sub(shape, "p", "spPr")
    add_transform(properties, x, y, width, height)
    geometry = sub(properties, "a", "prstGeom", {"prst": "roundRect" if rounded else "rect"})
    sub(geometry, "a", "avLst")
    solid = sub(properties, "a", "solidFill")
    sub(solid, "a", "srgbClr", {"val": fill})
    sub(properties, "a", "ln", {"w": "0"})
    return shape_id + 1


def add_text(tree, shape_id, text, x, y, width, height, size, color, bold=False):
    shape = sub(tree, "p", "sp")
    nv = sub(shape, "p", "nvSpPr")
    sub(nv, "p", "cNvPr", {"id": str(shape_id), "name": f"Text {shape_id}"})
    sub(nv, "p", "cNvSpPr", {"txBox": "1"})
    sub(nv, "p", "nvPr")
    properties = sub(shape, "p", "spPr")
    add_transform(properties, x, y, width, height)
    geometry = sub(properties, "a", "prstGeom", {"prst": "rect"})
    sub(geometry, "a", "avLst")
    sub(properties, "a", "noFill")
    line = sub(properties, "a", "ln")
    sub(line, "a", "noFill")
    body = sub(shape, "p", "txBody")
    sub(body, "a", "bodyPr", {"wrap": "square", "rtlCol": "1", "anchor": "ctr"})
    sub(body, "a", "lstStyle")
    paragraph = sub(body, "a", "p")
    sub(paragraph, "a", "pPr", {"algn": "r", "rtl": "1"})
    run = sub(paragraph, "a", "r")
    run_properties = sub(
        run,
        "a",
        "rPr",
        {"lang": "ar-SA", "sz": str(round(size * 100)), "b": "1" if bold else "0", "rtl": "1"},
    )
    fill = sub(run_properties, "a", "solidFill")
    sub(fill, "a", "srgbClr", {"val": color})
    sub(run_properties, "a", "latin", {"typeface": "Arial"})
    sub(run_properties, "a", "cs", {"typeface": "Arial"})
    text_node = sub(run, "a", "t")
    text_node.text = text
    sub(paragraph, "a", "endParaRPr", {"lang": "ar-SA", "sz": str(round(size * 100)), "rtl": "1"})
    return shape_id + 1


def shape_tree():
    tree = ET.Element(qname("p", "spTree"))
    nv = sub(tree, "p", "nvGrpSpPr")
    sub(nv, "p", "cNvPr", {"id": "1", "name": ""})
    sub(nv, "p", "cNvGrpSpPr")
    sub(nv, "p", "nvPr")
    group = sub(tree, "p", "grpSpPr")
    transform = sub(group, "a", "xfrm")
    sub(transform, "a", "off", {"x": "0", "y": "0"})
    sub(transform, "a", "ext", {"cx": "0", "cy": "0"})
    sub(transform, "a", "chOff", {"x": "0", "y": "0"})
    sub(transform, "a", "chExt", {"cx": "0", "cy": "0"})
    return tree


def make_slide(shapes):
    slide = ET.Element(qname("p", "sld"), {"showMasterSp": "1"})
    common = sub(slide, "p", "cSld")
    background = sub(common, "p", "bg")
    background_properties = sub(background, "p", "bgPr")
    solid = sub(background_properties, "a", "solidFill")
    sub(solid, "a", "srgbClr", {"val": INK})
    sub(background_properties, "a", "effectLst")
    tree = shape_tree()
    common.append(tree)
    shapes(tree)
    override = sub(slide, "p", "clrMapOvr")
    sub(override, "a", "masterClrMapping")
    return ET.tostring(slide, encoding="utf-8", xml_declaration=True)


def cover_shapes(tree):
    shape_id = 2
    shape_id = add_shape(tree, shape_id, 0.8, 1.12, 0.13, 4.95, TEAL, rounded=True)
    shape_id = add_shape(tree, shape_id, 1.08, 5.92, 5.1, 0.025, GOLD)
    shape_id = add_text(tree, shape_id, "اليونان القديمة", 1.25, 1.85, 10.8, 0.52, 25, TEAL, True)
    shape_id = add_text(tree, shape_id, "أسئلة ومراجعة", 1.25, 2.58, 10.8, 1.05, 43, PAPER, True)
    shape_id = add_text(tree, shape_id, "أربع محاور • ١١ سؤالًا", 1.25, 3.78, 10.8, 0.55, 21, GOLD, True)
    add_text(tree, shape_id, "من المدن المستقلة إلى الحضارة الهلنستية", 1.25, 4.48, 10.8, 0.48, 17, MUTED)


def content_shapes(group, group_index, total_questions):
    accent = ACCENTS[group_index % len(ACCENTS)]

    def draw(tree):
        shape_id = 2
        shape_id = add_text(tree, shape_id, f"المحور {group_index + 1:02d}", 0.8, 0.5, 11.7, 0.36, 13, accent, True)
        shape_id = add_text(tree, shape_id, group["title"], 0.8, 0.9, 11.7, 0.53, 25, PAPER, True)
        shape_id = add_shape(tree, shape_id, 0.8, 1.53, 11.7, 0.025, accent)

        items = group["questions"]
        card_height = 1.43 if len(items) == 3 else 1.62
        gap = 0.19
        first_y = 1.72 if len(items) == 3 else 2.12
        for item_index, item in enumerate(items):
            y = first_y + item_index * (card_height + gap)
            shape_id = add_shape(tree, shape_id, 0.8, y, 11.7, card_height, PANEL, rounded=True)
            label = f"السؤال {total_questions + item_index + 1:02d}"
            shape_id = add_text(tree, shape_id, label, 1.05, y + 0.12, 11.1, 0.25, 10, accent, True)
            shape_id = add_text(tree, shape_id, item["question"], 1.05, y + 0.38, 11.1, 0.43, 15, PAPER, True)
            answer = item.get("answer", " / ".join(item.get("choices", [])))
            add_text(tree, shape_id, f"الإجابة: {answer}", 1.05, y + 0.88, 11.1, 0.38, 12.5, MUTED)

        add_text(tree, 50, "اليونان القديمة", 0.8, 7.03, 11.7, 0.2, 9, MUTED)

    return draw


def relationships(entries):
    root = ET.Element(qname("rel", "Relationships"))
    for rel_id, rel_type, target in entries:
        ET.SubElement(
            root,
            qname("rel", "Relationship"),
            {"Id": rel_id, "Type": f"http://schemas.openxmlformats.org/officeDocument/2006/relationships/{rel_type}", "Target": target},
        )
    return ET.tostring(root, encoding="utf-8", xml_declaration=True)


def content_types(slide_count):
    root = ET.Element(qname("ct", "Types"))
    ET.SubElement(root, qname("ct", "Default"), {"Extension": "rels", "ContentType": "application/vnd.openxmlformats-package.relationships+xml"})
    ET.SubElement(root, qname("ct", "Default"), {"Extension": "xml", "ContentType": "application/xml"})
    overrides = {
        "/ppt/presentation.xml": "application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml",
        "/ppt/slideMasters/slideMaster1.xml": "application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml",
        "/ppt/slideLayouts/slideLayout1.xml": "application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml",
        "/ppt/theme/theme1.xml": "application/vnd.openxmlformats-officedocument.theme+xml",
    }
    overrides.update({f"/ppt/slides/slide{index}.xml": "application/vnd.openxmlformats-officedocument.presentationml.slide+xml" for index in range(1, slide_count + 1)})
    for part, content_type in overrides.items():
        ET.SubElement(root, qname("ct", "Override"), {"PartName": part, "ContentType": content_type})
    return ET.tostring(root, encoding="utf-8", xml_declaration=True)


def presentation(slide_count):
    root = ET.Element(qname("p", "presentation"))
    master_ids = sub(root, "p", "sldMasterIdLst")
    ET.SubElement(master_ids, qname("p", "sldMasterId"), {"id": "2147483648", qname("r", "id"): "rId1"})
    slide_ids = sub(root, "p", "sldIdLst")
    for index in range(1, slide_count + 1):
        ET.SubElement(slide_ids, qname("p", "sldId"), {"id": str(255 + index), qname("r", "id"): f"rId{index + 1}"})
    sub(root, "p", "sldSz", {"cx": str(round(WIDTH)), "cy": str(round(HEIGHT)), "type": "screen16x9"})
    sub(root, "p", "notesSz", {"cx": str(round(HEIGHT)), "cy": str(round(WIDTH))})
    return ET.tostring(root, encoding="utf-8", xml_declaration=True)


def simple_part(prefix, root_name, children):
    root = ET.Element(qname(prefix, root_name))
    for child_prefix, name, attrs in children:
        sub(root, child_prefix, name, attrs)
    return ET.tostring(root, encoding="utf-8", xml_declaration=True)


def theme_xml():
    xml = f'''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<a:theme xmlns:a="{NS['a']}" name="Ancient Greece">
  <a:themeElements>
    <a:clrScheme name="Greece"><a:dk1><a:srgbClr val="{INK}"/></a:dk1><a:lt1><a:srgbClr val="{PAPER}"/></a:lt1><a:dk2><a:srgbClr val="{PANEL}"/></a:dk2><a:lt2><a:srgbClr val="FFFFFF"/></a:lt2><a:accent1><a:srgbClr val="{TEAL}"/></a:accent1><a:accent2><a:srgbClr val="{GOLD}"/></a:accent2><a:accent3><a:srgbClr val="78B9E8"/></a:accent3><a:accent4><a:srgbClr val="E99178"/></a:accent4><a:accent5><a:srgbClr val="82958E"/></a:accent5><a:accent6><a:srgbClr val="E4E5E0"/></a:accent6><a:hlink><a:srgbClr val="0000FF"/></a:hlink><a:folHlink><a:srgbClr val="800080"/></a:folHlink></a:clrScheme>
    <a:fontScheme name="Arabic"><a:majorFont><a:latin typeface="Arial"/><a:ea typeface="Arial"/><a:cs typeface="Arial"/></a:majorFont><a:minorFont><a:latin typeface="Arial"/><a:ea typeface="Arial"/><a:cs typeface="Arial"/></a:minorFont></a:fontScheme>
        <a:fmtScheme name="Simple">
            <a:fillStyleLst><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:solidFill><a:schemeClr val="phClr"/></a:solidFill></a:fillStyleLst>
            <a:lnStyleLst><a:ln w="6350"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:prstDash val="solid"/></a:ln><a:ln w="12700"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:prstDash val="solid"/></a:ln><a:ln w="19050"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:prstDash val="solid"/></a:ln></a:lnStyleLst>
            <a:effectStyleLst><a:effectStyle><a:effectLst/></a:effectStyle><a:effectStyle><a:effectLst/></a:effectStyle><a:effectStyle><a:effectLst/></a:effectStyle></a:effectStyleLst>
            <a:bgFillStyleLst><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:solidFill><a:schemeClr val="phClr"/></a:solidFill></a:bgFillStyleLst>
        </a:fmtScheme>
  </a:themeElements>
</a:theme>'''
    return xml.encode("utf-8")


def write_presentation(data):
    groups = data["groups"]
    slide_count = len(groups) + 1
    slide_functions = [cover_shapes]
    question_count = 0
    for group_index, group in enumerate(groups):
        slide_functions.append(content_shapes(group, group_index, question_count))
        question_count += len(group["questions"])

    master = simple_part("p", "sldMaster", [
        ("p", "cSld", {}),
        ("p", "clrMap", {"bg1": "lt1", "tx1": "dk1", "bg2": "lt2", "tx2": "dk2", "accent1": "accent1", "accent2": "accent2", "accent3": "accent3", "accent4": "accent4", "accent5": "accent5", "accent6": "accent6", "hlink": "hlink", "folHlink": "folHlink"}),
        ("p", "sldLayoutIdLst", {}),
        ("p", "txStyles", {}),
    ])
    layout = simple_part("p", "sldLayout", [("p", "cSld", {}), ("p", "clrMapOvr", {})])
    master_root = ET.fromstring(master)
    master_root.find(qname("p", "cSld")).append(shape_tree())
    master_root.find(qname("p", "sldLayoutIdLst")).append(ET.Element(qname("p", "sldLayoutId"), {"id": "1", qname("r", "id"): "rId1"}))
    text_styles = master_root.find(qname("p", "txStyles"))
    for style_name in ("titleStyle", "bodyStyle", "otherStyle"):
        style = sub(text_styles, "p", style_name)
        level = sub(style, "a", "lvl1pPr")
        default_run = sub(level, "a", "defRPr", {"lang": "ar-SA"})
        sub(default_run, "a", "latin", {"typeface": "Arial"})
        sub(default_run, "a", "cs", {"typeface": "Arial"})
    layout_root = ET.fromstring(layout)
    layout_root.find(qname("p", "cSld")).append(shape_tree())
    layout_root.find(qname("p", "clrMapOvr")).append(ET.Element(qname("a", "masterClrMapping")))

    with zipfile.ZipFile(OUTPUT, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        archive.writestr("[Content_Types].xml", content_types(slide_count))
        archive.writestr("_rels/.rels", relationships([("rId1", "officeDocument", "ppt/presentation.xml")]))
        archive.writestr("ppt/presentation.xml", presentation(slide_count))
        presentation_rels = [("rId1", "slideMaster", "slideMasters/slideMaster1.xml")]
        presentation_rels.extend((f"rId{index + 1}", "slide", f"slides/slide{index}.xml") for index in range(1, slide_count + 1))
        archive.writestr("ppt/_rels/presentation.xml.rels", relationships(presentation_rels))
        archive.writestr("ppt/slideMasters/slideMaster1.xml", ET.tostring(master_root, encoding="utf-8", xml_declaration=True))
        archive.writestr("ppt/slideMasters/_rels/slideMaster1.xml.rels", relationships([
            ("rId1", "slideLayout", "../slideLayouts/slideLayout1.xml"),
            ("rId2", "theme", "../theme/theme1.xml"),
        ]))
        archive.writestr("ppt/slideLayouts/slideLayout1.xml", ET.tostring(layout_root, encoding="utf-8", xml_declaration=True))
        archive.writestr("ppt/slideLayouts/_rels/slideLayout1.xml.rels", relationships([("rId1", "slideMaster", "../slideMasters/slideMaster1.xml")]))
        archive.writestr("ppt/theme/theme1.xml", theme_xml())
        for index, draw in enumerate(slide_functions, start=1):
            archive.writestr(f"ppt/slides/slide{index}.xml", make_slide(draw))
            archive.writestr(f"ppt/slides/_rels/slide{index}.xml.rels", relationships([("rId1", "slideLayout", "../slideLayouts/slideLayout1.xml")]))

    with zipfile.ZipFile(OUTPUT) as archive:
        bad_member = archive.testzip()
        if bad_member:
            raise RuntimeError(f"Invalid PPTX archive member: {bad_member}")
        actual_slides = sum(name.startswith("ppt/slides/slide") and name.endswith(".xml") for name in archive.namelist())
        if actual_slides != slide_count:
            raise RuntimeError(f"Expected {slide_count} slides, found {actual_slides}")
    print(f"Created {OUTPUT.relative_to(ROOT)} with {slide_count} slides and {question_count} questions.")


if __name__ == "__main__":
    with SOURCE.open(encoding="utf-8") as source:
        question_data = json.load(source)
    write_presentation(question_data)