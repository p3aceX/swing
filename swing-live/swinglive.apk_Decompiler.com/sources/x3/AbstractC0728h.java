package x3;

import a.AbstractC0184a;
import java.util.AbstractCollection;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.RandomAccess;
import java.util.Set;

/* JADX INFO: renamed from: x3.h, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0728h extends n {
    public static Object X(List list) {
        if (list.isEmpty()) {
            return null;
        }
        return list.get(0);
    }

    public static final void Y(Iterable iterable, StringBuilder sb, CharSequence charSequence, CharSequence charSequence2, CharSequence charSequence3, CharSequence charSequence4, I3.l lVar) {
        J3.i.e(iterable, "<this>");
        sb.append(charSequence2);
        int i4 = 0;
        for (Object obj : iterable) {
            i4++;
            if (i4 > 1) {
                sb.append(charSequence);
            }
            AbstractC0184a.f(sb, obj, lVar);
        }
        sb.append(charSequence3);
    }

    public static String a0(Iterable iterable, String str, String str2, String str3, I3.l lVar, int i4) {
        if ((i4 & 1) != 0) {
            str = ", ";
        }
        String str4 = str;
        String str5 = (i4 & 2) != 0 ? "" : str2;
        String str6 = (i4 & 4) != 0 ? "" : str3;
        if ((i4 & 32) != 0) {
            lVar = null;
        }
        J3.i.e(iterable, "<this>");
        StringBuilder sb = new StringBuilder();
        Y(iterable, sb, str4, str5, str6, "...", lVar);
        return sb.toString();
    }

    public static Object b0(List list) {
        if (list.isEmpty()) {
            return null;
        }
        return list.get(list.size() - 1);
    }

    public static ArrayList c0(Collection collection, List list) {
        J3.i.e(collection, "<this>");
        ArrayList arrayList = new ArrayList(list.size() + collection.size());
        arrayList.addAll(collection);
        arrayList.addAll(list);
        return arrayList;
    }

    public static List d0(List list) {
        J3.i.e(list, "<this>");
        if (list.size() <= 1) {
            return i0(list);
        }
        List listL0 = l0(list);
        Collections.reverse(listL0);
        return listL0;
    }

    public static List e0(int i4, List list) {
        J3.i.e(list, "<this>");
        if (i4 < 0) {
            throw new IllegalArgumentException(B1.a.l("Requested element count ", i4, " is less than zero.").toString());
        }
        p pVar = p.f6784a;
        if (i4 == 0) {
            return pVar;
        }
        if (i4 >= list.size()) {
            return i0(list);
        }
        if (i4 == 1) {
            if (list.isEmpty()) {
                throw new NoSuchElementException("List is empty.");
            }
            return e1.k.x(list.get(0));
        }
        ArrayList arrayList = new ArrayList(i4);
        Iterator it = list.iterator();
        int i5 = 0;
        while (it.hasNext()) {
            arrayList.add(it.next());
            i5++;
            if (i5 == i4) {
                break;
            }
        }
        int size = arrayList.size();
        return size != 0 ? size != 1 ? arrayList : e1.k.x(arrayList.get(0)) : pVar;
    }

    public static byte[] f0(List list) {
        J3.i.e(list, "<this>");
        byte[] bArr = new byte[list.size()];
        Iterator it = list.iterator();
        int i4 = 0;
        while (it.hasNext()) {
            bArr[i4] = ((Number) it.next()).byteValue();
            i4++;
        }
        return bArr;
    }

    public static final void g0(Iterable iterable, AbstractCollection abstractCollection) {
        J3.i.e(iterable, "<this>");
        Iterator it = iterable.iterator();
        while (it.hasNext()) {
            abstractCollection.add(it.next());
        }
    }

    public static int[] h0(ArrayList arrayList) {
        int[] iArr = new int[arrayList.size()];
        Iterator it = arrayList.iterator();
        int i4 = 0;
        while (it.hasNext()) {
            iArr[i4] = ((Number) it.next()).intValue();
            i4++;
        }
        return iArr;
    }

    public static List i0(Iterable iterable) {
        J3.i.e(iterable, "<this>");
        boolean z4 = iterable instanceof Collection;
        p pVar = p.f6784a;
        if (!z4) {
            List listL0 = l0(iterable);
            ArrayList arrayList = (ArrayList) listL0;
            int size = arrayList.size();
            return size != 0 ? size != 1 ? listL0 : e1.k.x(arrayList.get(0)) : pVar;
        }
        Collection collection = (Collection) iterable;
        int size2 = collection.size();
        if (size2 == 0) {
            return pVar;
        }
        if (size2 != 1) {
            return k0(collection);
        }
        return e1.k.x(iterable instanceof List ? ((List) iterable).get(0) : collection.iterator().next());
    }

    public static long[] j0(List list) {
        J3.i.e(list, "<this>");
        long[] jArr = new long[list.size()];
        Iterator it = list.iterator();
        int i4 = 0;
        while (it.hasNext()) {
            jArr[i4] = ((Number) it.next()).longValue();
            i4++;
        }
        return jArr;
    }

    public static ArrayList k0(Collection collection) {
        J3.i.e(collection, "<this>");
        return new ArrayList(collection);
    }

    public static final List l0(Iterable iterable) {
        J3.i.e(iterable, "<this>");
        if (iterable instanceof Collection) {
            return k0((Collection) iterable);
        }
        ArrayList arrayList = new ArrayList();
        g0(iterable, arrayList);
        return arrayList;
    }

    public static Set m0(Collection collection) {
        J3.i.e(collection, "<this>");
        boolean z4 = collection instanceof Collection;
        r rVar = r.f6786a;
        if (z4) {
            Collection collection2 = collection;
            int size = collection2.size();
            if (size != 0) {
                if (size != 1) {
                    LinkedHashSet linkedHashSet = new LinkedHashSet(s.c0(collection2.size()));
                    g0(collection, linkedHashSet);
                    return linkedHashSet;
                }
                Set setSingleton = Collections.singleton(collection instanceof List ? ((List) collection).get(0) : collection2.iterator().next());
                J3.i.d(setSingleton, "singleton(...)");
                return setSingleton;
            }
        } else {
            LinkedHashSet linkedHashSet2 = new LinkedHashSet();
            g0(collection, linkedHashSet2);
            int size2 = linkedHashSet2.size();
            if (size2 != 0) {
                if (size2 != 1) {
                    return linkedHashSet2;
                }
                Set setSingleton2 = Collections.singleton(linkedHashSet2.iterator().next());
                J3.i.d(setSingleton2, "singleton(...)");
                return setSingleton2;
            }
        }
        return rVar;
    }

    public static ArrayList n0(List list, int i4, int i5) {
        Iterator it;
        J3.i.e(list, "<this>");
        e1.k.h(i4, i5);
        if (!(list instanceof RandomAccess)) {
            ArrayList arrayList = new ArrayList();
            Iterator it2 = list.iterator();
            J3.i.e(it2, "iterator");
            if (it2.hasNext()) {
                u uVar = new u(i4, i5, it2, null);
                O3.d dVar = new O3.d();
                dVar.f1465c = e1.k.l(uVar, dVar, dVar);
                it = dVar;
            } else {
                it = o.f6783a;
            }
            while (it.hasNext()) {
                arrayList.add((List) it.next());
            }
            return arrayList;
        }
        int size = list.size();
        ArrayList arrayList2 = new ArrayList((size / i5) + (size % i5 == 0 ? 0 : 1));
        int i6 = 0;
        while (i6 >= 0 && i6 < size) {
            int i7 = size - i6;
            if (i4 <= i7) {
                i7 = i4;
            }
            ArrayList arrayList3 = new ArrayList(i7);
            for (int i8 = 0; i8 < i7; i8++) {
                arrayList3.add(list.get(i8 + i6));
            }
            arrayList2.add(arrayList3);
            i6 += i5;
        }
        return arrayList2;
    }
}
