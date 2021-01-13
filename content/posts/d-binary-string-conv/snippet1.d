void main() {
  import std;
  write("enter binary number: ");
  readln
    .strip
    .compose!(retro,s=>s.all!"a=='0'||a=='1'"?s:"")
    .enumerate
    .map!"a[1]&'1'-48?2^^a[0]:0"
    .sum
    .writeln;
}