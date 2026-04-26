package P3;

import com.google.crypto.tink.shaded.protobuf.S;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import x3.AbstractC0730j;

/* JADX INFO: loaded from: classes.dex */
public abstract class m extends k {
    public static String A0(String str, String str2, String str3) {
        J3.i.e(str, "<this>");
        J3.i.e(str2, "oldValue");
        int iT0 = t0(str, str2, 0, false);
        if (iT0 < 0) {
            return str;
        }
        int length = str2.length();
        int i4 = length >= 1 ? length : 1;
        int length2 = str3.length() + (str.length() - length);
        if (length2 < 0) {
            throw new OutOfMemoryError();
        }
        StringBuilder sb = new StringBuilder(length2);
        int i5 = 0;
        do {
            sb.append((CharSequence) str, i5, iT0);
            sb.append(str3);
            i5 = iT0 + length;
            if (iT0 >= str.length()) {
                break;
            }
            iT0 = t0(str, str2, iT0 + i4, false);
        } while (iT0 > 0);
        sb.append((CharSequence) str, i5, str.length());
        String string = sb.toString();
        J3.i.d(string, "toString(...)");
        return string;
    }

    public static final void B0(int i4) {
        if (i4 < 0) {
            throw new IllegalArgumentException(S.d(i4, "Limit must be non-negative, but was ").toString());
        }
    }

    public static final List C0(CharSequence charSequence, String str) {
        B0(0);
        int iT0 = t0(charSequence, str, 0, false);
        if (iT0 == -1) {
            return e1.k.x(charSequence.toString());
        }
        ArrayList arrayList = new ArrayList(10);
        int length = 0;
        do {
            arrayList.add(charSequence.subSequence(length, iT0).toString());
            length = str.length() + iT0;
            iT0 = t0(charSequence, str, length, false);
        } while (iT0 != -1);
        arrayList.add(charSequence.subSequence(length, charSequence.length()).toString());
        return arrayList;
    }

    public static List D0(CharSequence charSequence, String[] strArr) {
        J3.i.e(charSequence, "<this>");
        if (strArr.length == 1) {
            String str = strArr[0];
            if (str.length() != 0) {
                return C0(charSequence, str);
            }
        }
        B0(0);
        List listAsList = Arrays.asList(strArr);
        J3.i.d(listAsList, "asList(...)");
        O3.h hVar = new O3.h(new c(charSequence, new l(listAsList, 1)));
        ArrayList arrayList = new ArrayList(AbstractC0730j.V(hVar));
        Iterator it = hVar.iterator();
        while (true) {
            b bVar = (b) it;
            if (!bVar.hasNext()) {
                return arrayList;
            }
            M3.f fVar = (M3.f) bVar.next();
            J3.i.e(fVar, "range");
            arrayList.add(charSequence.subSequence(fVar.f1095a, fVar.f1096b + 1).toString());
        }
    }

    public static List E0(String str, char[] cArr) {
        J3.i.e(str, "<this>");
        if (cArr.length == 1) {
            return C0(str, String.valueOf(cArr[0]));
        }
        B0(0);
        O3.h hVar = new O3.h(new c(str, new l(cArr, 0)));
        ArrayList arrayList = new ArrayList(AbstractC0730j.V(hVar));
        Iterator it = hVar.iterator();
        while (true) {
            b bVar = (b) it;
            if (!bVar.hasNext()) {
                return arrayList;
            }
            M3.f fVar = (M3.f) bVar.next();
            J3.i.e(fVar, "range");
            arrayList.add(str.subSequence(fVar.f1095a, fVar.f1096b + 1).toString());
        }
    }

    public static boolean F0(String str, String str2) {
        J3.i.e(str, "<this>");
        J3.i.e(str2, "prefix");
        return str.startsWith(str2);
    }

    public static String G0(String str, String str2) {
        J3.i.e(str2, "delimiter");
        int iU0 = u0(0, 6, str, str2, false);
        if (iU0 == -1) {
            return str;
        }
        String strSubstring = str.substring(str2.length() + iU0, str.length());
        J3.i.d(strSubstring, "substring(...)");
        return strSubstring;
    }

    public static String H0(String str, String str2) {
        J3.i.e(str, "<this>");
        J3.i.e(str, "missingDelimiterValue");
        int iU0 = u0(0, 6, str, str2, false);
        if (iU0 == -1) {
            return str;
        }
        String strSubstring = str.substring(0, iU0);
        J3.i.d(strSubstring, "substring(...)");
        return strSubstring;
    }

    public static Integer I0(String str) {
        boolean z4;
        int i4;
        H0.a.c(10);
        int length = str.length();
        if (length == 0) {
            return null;
        }
        int i5 = 0;
        char cCharAt = str.charAt(0);
        int i6 = 1;
        int i7 = -2147483647;
        if ((cCharAt < '0' ? (byte) -1 : cCharAt == '0' ? (byte) 0 : (byte) 1) >= 0) {
            z4 = false;
            i6 = 0;
        } else {
            if (length == 1) {
                return null;
            }
            if (cCharAt == '+') {
                z4 = false;
            } else {
                if (cCharAt != '-') {
                    return null;
                }
                i7 = Integer.MIN_VALUE;
                z4 = true;
            }
        }
        int i8 = -59652323;
        while (i6 < length) {
            int iDigit = Character.digit((int) str.charAt(i6), 10);
            if (iDigit < 0) {
                return null;
            }
            if ((i5 < i8 && (i8 != -59652323 || i5 < (i8 = i7 / 10))) || (i4 = i5 * 10) < i7 + iDigit) {
                return null;
            }
            i5 = i4 - iDigit;
            i6++;
        }
        return z4 ? Integer.valueOf(i5) : Integer.valueOf(-i5);
    }

    public static CharSequence J0(String str) {
        J3.i.e(str, "<this>");
        int length = str.length() - 1;
        int i4 = 0;
        boolean z4 = false;
        while (i4 <= length) {
            boolean zO = H0.a.O(str.charAt(!z4 ? i4 : length));
            if (z4) {
                if (!zO) {
                    break;
                }
                length--;
            } else if (zO) {
                i4++;
            } else {
                z4 = true;
            }
        }
        return str.subSequence(i4, length + 1);
    }

    public static boolean q0(String str, String str2, boolean z4) {
        J3.i.e(str, "<this>");
        return u0(0, 2, str, str2, z4) >= 0;
    }

    public static final int s0(CharSequence charSequence) {
        J3.i.e(charSequence, "<this>");
        return charSequence.length() - 1;
    }

    public static final int t0(CharSequence charSequence, String str, int i4, boolean z4) {
        J3.i.e(charSequence, "<this>");
        J3.i.e(str, "string");
        if (!z4 && (charSequence instanceof String)) {
            return ((String) charSequence).indexOf(str, i4);
        }
        int length = charSequence.length();
        if (i4 < 0) {
            i4 = 0;
        }
        int length2 = charSequence.length();
        if (length > length2) {
            length = length2;
        }
        M3.f fVar = new M3.f(i4, length, 1);
        boolean z5 = charSequence instanceof String;
        int i5 = fVar.f1097c;
        int i6 = fVar.f1096b;
        int i7 = fVar.f1095a;
        if (!z5 || str == null) {
            if ((i5 <= 0 || i7 > i6) && (i5 >= 0 || i6 > i7)) {
                return -1;
            }
            while (!y0(i7, str.length(), charSequence, str, z4)) {
                if (i7 == i6) {
                    return -1;
                }
                i7 += i5;
            }
            return i7;
        }
        if ((i5 <= 0 || i7 > i6) && (i5 >= 0 || i6 > i7)) {
            return -1;
        }
        int i8 = i7;
        while (true) {
            String str2 = str;
            boolean z6 = z4;
            if (x0(0, i8, str.length(), str2, (String) charSequence, z6)) {
                return i8;
            }
            if (i8 == i6) {
                return -1;
            }
            i8 += i5;
            str = str2;
            z4 = z6;
        }
    }

    public static /* synthetic */ int u0(int i4, int i5, CharSequence charSequence, String str, boolean z4) {
        if ((i5 & 2) != 0) {
            i4 = 0;
        }
        if ((i5 & 4) != 0) {
            z4 = false;
        }
        return t0(charSequence, str, i4, z4);
    }

    public static boolean v0(CharSequence charSequence) {
        J3.i.e(charSequence, "<this>");
        for (int i4 = 0; i4 < charSequence.length(); i4++) {
            if (!H0.a.O(charSequence.charAt(i4))) {
                return false;
            }
        }
        return true;
    }

    public static String w0(int i4, String str) {
        CharSequence charSequenceSubSequence;
        J3.i.e(str, "<this>");
        if (i4 < 0) {
            throw new IllegalArgumentException(B1.a.l("Desired length ", i4, " is less than zero."));
        }
        if (i4 <= str.length()) {
            charSequenceSubSequence = str.subSequence(0, str.length());
        } else {
            StringBuilder sb = new StringBuilder(i4);
            sb.append((CharSequence) str);
            int length = i4 - str.length();
            int i5 = 1;
            if (1 <= length) {
                while (true) {
                    sb.append(' ');
                    if (i5 == length) {
                        break;
                    }
                    i5++;
                }
            }
            charSequenceSubSequence = sb;
        }
        return charSequenceSubSequence.toString();
    }

    public static final boolean x0(int i4, int i5, int i6, String str, String str2, boolean z4) {
        J3.i.e(str, "<this>");
        J3.i.e(str2, "other");
        return !z4 ? str.regionMatches(i4, str2, i5, i6) : str.regionMatches(z4, i4, str2, i5, i6);
    }

    public static final boolean y0(int i4, int i5, CharSequence charSequence, String str, boolean z4) {
        char upperCase;
        char upperCase2;
        J3.i.e(str, "<this>");
        J3.i.e(charSequence, "other");
        if (i4 >= 0 && str.length() - i5 >= 0 && i4 <= charSequence.length() - i5) {
            for (int i6 = 0; i6 < i5; i6++) {
                char cCharAt = str.charAt(i6);
                char cCharAt2 = charSequence.charAt(i4 + i6);
                if (cCharAt == cCharAt2 || (z4 && ((upperCase = Character.toUpperCase(cCharAt)) == (upperCase2 = Character.toUpperCase(cCharAt2)) || Character.toLowerCase(upperCase) == Character.toLowerCase(upperCase2)))) {
                }
            }
            return true;
        }
        return false;
    }

    public static String z0(String str, String str2) {
        J3.i.e(str, "<this>");
        J3.i.e(str2, "prefix");
        if (!F0(str, str2)) {
            return str;
        }
        String strSubstring = str.substring(str2.length());
        J3.i.d(strSubstring, "substring(...)");
        return strSubstring;
    }
}
