import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:safety_check/app/constant/constants.dart';
import 'package:safety_check/app/data/models/04_fault.dart';
import 'package:safety_check/app/modules/drawing_detail/views/marker_row.dart';

class FaultTable extends StatefulWidget {
  const FaultTable({
    super.key,
    required this.tableData,
    this.onTapRow,
  });

  // 타입 변경: 동 > 층 > 마커 구조로 업데이트
  final RxMap<String, Map<int, Map<String, List<Fault>>>> tableData;
  final void Function(Fault)? onTapRow;

  @override
  State<FaultTable> createState() => FaultTableState();
}

class FaultTableState extends State<FaultTable> {
  LinkedScrollControllerGroup controllers = LinkedScrollControllerGroup();
  late ScrollController scrollController1;
  late ScrollController scrollController2;

  @override
  void initState() {
    scrollController1 = controllers.addAndGet();
    scrollController2 = controllers.addAndGet();
    super.initState();
  }

  @override
  void dispose() {
    scrollController1.dispose();
    scrollController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - appBarHeight,
        ),
        Column(
          children: [
            // 테이블 헤더
            Container(
              color: Color(0xffDDE3EC),
              child: Row(
                children: [
                  Container(
                      width: tableSize["seq"],
                      height: tableSize["header_height"],
                      decoration: BoxDecoration(
                          border: Border.all(color: Color(0xffCCCCCC))),
                      child: Center(child: Text("구분"))),
                  Expanded(
                    child: SizedBox(
                      height: tableSize["header_height"]!,
                      child: Row(
                        children: [
                          Container(
                              width: tableSize["location"],
                              decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xffCCCCCC))),
                              child: Center(child: Text("부위"))),
                          Container(
                              width: tableSize["element"],
                              decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xffCCCCCC))),
                              child: Center(child: Text("부재"))),
                          Expanded(
                              child: Container(
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Color(0xffCCCCCC))),
                                  child: Center(child: Text("유형 및 형상")))),
                          Container(
                              width: tableSize["width"],
                              decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xffCCCCCC))),
                              child: Center(child: Text("폭"))),
                          Container(
                              width: tableSize["length"],
                              decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xffCCCCCC))),
                              child: Center(child: Text("길이"))),
                          Container(
                              width: tableSize["qty"],
                              decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xffCCCCCC))),
                              child: Center(child: AutoSizeText("개소"))),
                          Container(
                              width: tableSize["ing_yn"],
                              decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xffCCCCCC))),
                              child: Center(child: AutoSizeText("진행"))),
                          Container(
                              width: tableSize["status"],
                              decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xffCCCCCC))),
                              child: Center(child: AutoSizeText("상태"))),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: tableSize["note"],
                    height: tableSize["header_height"],
                    decoration: BoxDecoration(
                        border: Border.all(color: Color(0xffCCCCCC))),
                    child: Center(child: Text("비고")),
                  ),
                  Container(
                    width: tableSize["pic_no"],
                    height: tableSize["header_height"],
                    decoration: BoxDecoration(
                        border: Border.all(color: Color(0xffCCCCCC))),
                    child: Center(child: Text("사진")),
                  ),
                ],
              ),
            ),
            // 테이블 내용
            Expanded(
              child: CupertinoScrollbar(
                controller: scrollController1,
                child: SingleChildScrollView(
                  controller: scrollController1,
                  child: Obx(() {
                    // 동이 없는 경우 처리
                    if (widget.tableData.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text("데이터가 없습니다"),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        // 각 동별로 섹션 생성
                        ...widget.tableData.entries.map((dongEntry) {
                          String? dongName =
                              dongEntry.key == "" ? null : dongEntry.key;
                          Map<int, Map<String, List<Fault>>> floorMap =
                              dongEntry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 동 이름 헤더 (대분류)
                              if (widget.tableData.length > 1)
                                Container(
                                  color: Colors.red.shade50,
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 16),
                                  child: Text(
                                    dongName ?? "이름없음",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),

                              // 각 층별로 섹션 생성
                              ...floorMap.entries.map((floorEntry) {
                                // int floor = floorEntry.key;
                                Map<String, List<Fault>> markerMap =
                                    floorEntry.value;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 층 이름 헤더 (중분류)
                                    if (widget.tableData.length > 1 ||
                                        widget.tableData.values.first.length >
                                            1)
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ),
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 32),
                                        child: Text(
                                          floorEntry.value.values.first.first
                                                  .floor_name ??
                                              "층이름없음",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),

                                    // 각 마커별 결함 행 생성
                                    ...markerMap.entries.map((markerEntry) {
                                      String markerNo = markerEntry.key;
                                      List<Fault> faultList = markerEntry.value;

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 0.2),
                                        child: MarkerRow(
                                          markerNo: markerNo,
                                          faultList: faultList,
                                          onTapRow: widget.onTapRow,
                                        ),
                                      );
                                    }),
                                  ],
                                );
                              }),
                            ],
                          );
                        }),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
