package P3;

import a.AbstractC0184a;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import x3.AbstractC0728h;
import x3.AbstractC0729i;
import x3.AbstractC0730j;

/* JADX INFO: loaded from: classes.dex */
public abstract class f extends AbstractC0184a {
    public static String p0(String str) {
        int length;
        Comparable comparable;
        String strSubstring;
        J3.i.e(str, "<this>");
        List listO0 = O3.e.o0(new O3.f(str, 2));
        ArrayList arrayList = new ArrayList();
        for (Object obj : listO0) {
            if (!m.v0((String) obj)) {
                arrayList.add(obj);
            }
        }
        ArrayList arrayList2 = new ArrayList(AbstractC0730j.V(arrayList));
        Iterator it = arrayList.iterator();
        while (true) {
            length = 0;
            if (!it.hasNext()) {
                break;
            }
            String str2 = (String) it.next();
            int length2 = str2.length();
            while (true) {
                if (length >= length2) {
                    length = -1;
                    break;
                }
                if (!H0.a.O(str2.charAt(length))) {
                    break;
                }
                length++;
            }
            if (length == -1) {
                length = str2.length();
            }
            arrayList2.add(Integer.valueOf(length));
        }
        Iterator it2 = arrayList2.iterator();
        if (it2.hasNext()) {
            comparable = (Comparable) it2.next();
            while (it2.hasNext()) {
                Comparable comparable2 = (Comparable) it2.next();
                if (comparable.compareTo(comparable2) > 0) {
                    comparable = comparable2;
                }
            }
        } else {
            comparable = null;
        }
        Integer num = (Integer) comparable;
        int iIntValue = num != null ? num.intValue() : 0;
        int length3 = str.length();
        listO0.size();
        int iS = AbstractC0729i.S(listO0);
        ArrayList arrayList3 = new ArrayList();
        for (Object obj2 : listO0) {
            int i4 = length + 1;
            if (length < 0) {
                AbstractC0729i.U();
                throw null;
            }
            String str3 = (String) obj2;
            if ((length == 0 || length == iS) && m.v0(str3)) {
                strSubstring = null;
            } else {
                J3.i.e(str3, "<this>");
                if (iIntValue < 0) {
                    throw new IllegalArgumentException(B1.a.l("Requested character count ", iIntValue, " is less than zero.").toString());
                }
                int length4 = str3.length();
                if (iIntValue <= length4) {
                    length4 = iIntValue;
                }
                strSubstring = str3.substring(length4);
                J3.i.d(strSubstring, "substring(...)");
            }
            if (strSubstring != null) {
                arrayList3.add(strSubstring);
            }
            length = i4;
        }
        StringBuilder sb = new StringBuilder(length3);
        AbstractC0728h.Y(arrayList3, sb, "\n", "", "", "...", null);
        return sb.toString();
    }
}
