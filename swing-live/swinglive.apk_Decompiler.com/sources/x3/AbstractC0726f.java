package x3;

import Q3.C0152y;
import e1.AbstractC0367g;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.NoSuchElementException;

/* JADX INFO: renamed from: x3.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0726f extends AbstractC0367g {
    public static boolean c0(Object[] objArr, Object obj) {
        int i4;
        J3.i.e(objArr, "<this>");
        if (obj == null) {
            int length = objArr.length;
            i4 = 0;
            while (i4 < length) {
                if (objArr[i4] == null) {
                    break;
                }
                i4++;
            }
            i4 = -1;
        } else {
            int length2 = objArr.length;
            for (int i5 = 0; i5 < length2; i5++) {
                if (obj.equals(objArr[i5])) {
                    i4 = i5;
                    break;
                }
            }
            i4 = -1;
        }
        return i4 >= 0;
    }

    public static void d0(byte[] bArr, int i4, byte[] bArr2, int i5, int i6) {
        J3.i.e(bArr, "<this>");
        J3.i.e(bArr2, "destination");
        System.arraycopy(bArr, i5, bArr2, i4, i6 - i5);
    }

    public static final void e0(Object[] objArr, int i4, Object[] objArr2, int i5, int i6) {
        J3.i.e(objArr, "<this>");
        J3.i.e(objArr2, "destination");
        System.arraycopy(objArr, i5, objArr2, i4, i6 - i5);
    }

    public static byte[] f0(byte[] bArr, int i4, int i5) {
        J3.i.e(bArr, "<this>");
        int length = bArr.length;
        if (i5 <= length) {
            byte[] bArrCopyOfRange = Arrays.copyOfRange(bArr, i4, i5);
            J3.i.d(bArrCopyOfRange, "copyOfRange(...)");
            return bArrCopyOfRange;
        }
        throw new IndexOutOfBoundsException("toIndex (" + i5 + ") is greater than size (" + length + ").");
    }

    public static final void g0(Object[] objArr, int i4, int i5) {
        J3.i.e(objArr, "<this>");
        Arrays.fill(objArr, i4, i5, (Object) null);
    }

    public static Object h0(Object[] objArr) {
        J3.i.e(objArr, "<this>");
        if (objArr.length != 0) {
            return objArr[0];
        }
        throw new NoSuchElementException("Array is empty.");
    }

    public static String i0(byte[] bArr, String str, C0152y c0152y, int i4) {
        if ((i4 & 1) != 0) {
            str = ", ";
        }
        String str2 = (i4 & 2) != 0 ? "" : "[";
        String str3 = (i4 & 4) == 0 ? "]" : "";
        if ((i4 & 32) != 0) {
            c0152y = null;
        }
        J3.i.e(bArr, "<this>");
        StringBuilder sb = new StringBuilder();
        sb.append((CharSequence) str2);
        int i5 = 0;
        for (byte b5 : bArr) {
            i5++;
            if (i5 > 1) {
                sb.append((CharSequence) str);
            }
            if (c0152y != null) {
                sb.append((CharSequence) c0152y.invoke(Byte.valueOf(b5)));
            } else {
                sb.append((CharSequence) String.valueOf((int) b5));
            }
        }
        sb.append((CharSequence) str3);
        return sb.toString();
    }

    public static byte[] j0(byte[] bArr, byte[] bArr2) {
        J3.i.e(bArr, "<this>");
        J3.i.e(bArr2, "elements");
        int length = bArr.length;
        int length2 = bArr2.length;
        byte[] bArrCopyOf = Arrays.copyOf(bArr, length + length2);
        System.arraycopy(bArr2, 0, bArrCopyOf, length, length2);
        J3.i.b(bArrCopyOf);
        return bArrCopyOf;
    }

    public static byte[] k0(byte[] bArr, M3.f fVar) {
        J3.i.e(bArr, "<this>");
        J3.i.e(fVar, "indices");
        if (fVar.isEmpty()) {
            return new byte[0];
        }
        return f0(bArr, fVar.f1095a, fVar.f1096b + 1);
    }

    public static List l0(byte[] bArr) {
        J3.i.e(bArr, "<this>");
        int length = bArr.length;
        if (length == 0) {
            return p.f6784a;
        }
        if (length == 1) {
            return e1.k.x(Byte.valueOf(bArr[0]));
        }
        ArrayList arrayList = new ArrayList(bArr.length);
        for (byte b5 : bArr) {
            arrayList.add(Byte.valueOf(b5));
        }
        return arrayList;
    }

    public static List m0(long[] jArr) {
        J3.i.e(jArr, "<this>");
        int length = jArr.length;
        if (length == 0) {
            return p.f6784a;
        }
        if (length == 1) {
            return e1.k.x(Long.valueOf(jArr[0]));
        }
        ArrayList arrayList = new ArrayList(jArr.length);
        for (long j4 : jArr) {
            arrayList.add(Long.valueOf(j4));
        }
        return arrayList;
    }

    public static List n0(Object[] objArr) {
        J3.i.e(objArr, "<this>");
        int length = objArr.length;
        return length != 0 ? length != 1 ? new ArrayList(new C0724d(objArr, false)) : e1.k.x(objArr[0]) : p.f6784a;
    }
}
