package com.example.demo.vo;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import java.util.List;

@Getter
@Setter
@ToString
public class BookInfoListBDTO {

   private Long cntLong;   
   private List<BookInfoVO> books;


}
