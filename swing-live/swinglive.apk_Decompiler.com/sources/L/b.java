package L;

import J3.i;
import java.util.Arrays;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.atomic.AtomicBoolean;
import x3.AbstractC0728h;
import x3.AbstractC0730j;
import x3.s;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final LinkedHashMap f861a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final C0779j f862b;

    public b(LinkedHashMap linkedHashMap, boolean z4) {
        this.f861a = linkedHashMap;
        this.f862b = new C0779j(z4);
    }

    public final Map a() {
        w3.c cVar;
        Set<Map.Entry> setEntrySet = this.f861a.entrySet();
        int iC0 = s.c0(AbstractC0730j.V(setEntrySet));
        if (iC0 < 16) {
            iC0 = 16;
        }
        LinkedHashMap linkedHashMap = new LinkedHashMap(iC0);
        for (Map.Entry entry : setEntrySet) {
            Object value = entry.getValue();
            if (value instanceof byte[]) {
                Object key = entry.getKey();
                byte[] bArr = (byte[]) value;
                byte[] bArrCopyOf = Arrays.copyOf(bArr, bArr.length);
                i.d(bArrCopyOf, "copyOf(this, size)");
                cVar = new w3.c(key, bArrCopyOf);
            } else {
                cVar = new w3.c(entry.getKey(), entry.getValue());
            }
            linkedHashMap.put(cVar.f6718a, cVar.f6719b);
        }
        Map mapUnmodifiableMap = Collections.unmodifiableMap(linkedHashMap);
        i.d(mapUnmodifiableMap, "unmodifiableMap(map)");
        return mapUnmodifiableMap;
    }

    public final void b() {
        if (((AtomicBoolean) this.f862b.f6969b).get()) {
            throw new IllegalStateException("Do mutate preferences once returned to DataStore.");
        }
    }

    public final Object c(d dVar) {
        i.e(dVar, "key");
        Object obj = this.f861a.get(dVar);
        if (!(obj instanceof byte[])) {
            return obj;
        }
        byte[] bArr = (byte[]) obj;
        byte[] bArrCopyOf = Arrays.copyOf(bArr, bArr.length);
        i.d(bArrCopyOf, "copyOf(this, size)");
        return bArrCopyOf;
    }

    public final void d(d dVar, Object obj) {
        b();
        LinkedHashMap linkedHashMap = this.f861a;
        if (obj == null) {
            b();
            linkedHashMap.remove(dVar);
            return;
        }
        if (obj instanceof Set) {
            Set setUnmodifiableSet = Collections.unmodifiableSet(AbstractC0728h.m0((Set) obj));
            i.d(setUnmodifiableSet, "unmodifiableSet(set.toSet())");
            linkedHashMap.put(dVar, setUnmodifiableSet);
        } else {
            if (!(obj instanceof byte[])) {
                linkedHashMap.put(dVar, obj);
                return;
            }
            byte[] bArr = (byte[]) obj;
            byte[] bArrCopyOf = Arrays.copyOf(bArr, bArr.length);
            i.d(bArrCopyOf, "copyOf(this, size)");
            linkedHashMap.put(dVar, bArrCopyOf);
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:27:0x005f  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final boolean equals(java.lang.Object r7) {
        /*
            r6 = this;
            boolean r0 = r7 instanceof L.b
            r1 = 0
            if (r0 != 0) goto L6
            goto L62
        L6:
            L.b r7 = (L.b) r7
            java.util.LinkedHashMap r0 = r7.f861a
            java.util.LinkedHashMap r2 = r6.f861a
            r3 = 1
            if (r0 != r2) goto L10
            goto L63
        L10:
            int r0 = r0.size()
            int r4 = r2.size()
            if (r0 == r4) goto L1b
            goto L62
        L1b:
            java.util.LinkedHashMap r7 = r7.f861a
            boolean r0 = r7.isEmpty()
            if (r0 == 0) goto L24
            goto L63
        L24:
            java.util.Set r7 = r7.entrySet()
            java.util.Iterator r7 = r7.iterator()
        L2c:
            boolean r0 = r7.hasNext()
            if (r0 == 0) goto L63
            java.lang.Object r0 = r7.next()
            java.util.Map$Entry r0 = (java.util.Map.Entry) r0
            java.lang.Object r4 = r0.getKey()
            java.lang.Object r4 = r2.get(r4)
            if (r4 == 0) goto L5f
            java.lang.Object r0 = r0.getValue()
            boolean r5 = r0 instanceof byte[]
            if (r5 == 0) goto L5a
            boolean r5 = r4 instanceof byte[]
            if (r5 == 0) goto L5f
            byte[] r0 = (byte[]) r0
            byte[] r4 = (byte[]) r4
            boolean r0 = java.util.Arrays.equals(r0, r4)
            if (r0 == 0) goto L5f
            r0 = r3
            goto L60
        L5a:
            boolean r0 = J3.i.a(r0, r4)
            goto L60
        L5f:
            r0 = r1
        L60:
            if (r0 != 0) goto L2c
        L62:
            return r1
        L63:
            return r3
        */
        throw new UnsupportedOperationException("Method not decompiled: L.b.equals(java.lang.Object):boolean");
    }

    public final int hashCode() {
        Iterator it = this.f861a.entrySet().iterator();
        int iHashCode = 0;
        while (it.hasNext()) {
            Object value = ((Map.Entry) it.next()).getValue();
            iHashCode += value instanceof byte[] ? Arrays.hashCode((byte[]) value) : value.hashCode();
        }
        return iHashCode;
    }

    public final String toString() {
        return AbstractC0728h.a0(this.f861a.entrySet(), ",\n", "{\n", "\n}", a.f860a, 24);
    }

    public /* synthetic */ b(boolean z4) {
        this(new LinkedHashMap(), z4);
    }
}
