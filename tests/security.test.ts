import {describe,it,expect} from 'vitest'; import {slugify,listQuery,documentInput} from '../shared/validation';
describe('validation and isolation contracts',()=>{
 it('creates safe slugs',()=>expect(slugify('Maths / Term 1')).toBe('maths-term-1'));
 it('bounds pagination',()=>expect(listQuery.safeParse({page:'0'}).success).toBe(false));
 it('rejects unsafe slugs and missing metadata',()=>expect(documentInput.safeParse({title:'x',class_name:'1',subject:'Maths',academic_year:'2026',slug:'../private'}).success).toBe(false));
});
