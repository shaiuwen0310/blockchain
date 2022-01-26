import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { Paging2Component } from './paging2.component';

describe('Paging2Component', () => {
  let component: Paging2Component;
  let fixture: ComponentFixture<Paging2Component>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ Paging2Component ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(Paging2Component);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
