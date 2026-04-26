package m;

import java.util.Iterator;
import java.util.Map;
import java.util.WeakHashMap;

/* JADX INFO: renamed from: m.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public class C0544f implements Iterable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0541c f5758a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public C0541c f5759b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final WeakHashMap f5760c = new WeakHashMap();

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f5761d = 0;

    /* JADX WARN: Code restructure failed: missing block: B:24:0x0048, code lost:
    
        if (r3.hasNext() != false) goto L28;
     */
    /* JADX WARN: Code restructure failed: missing block: B:26:0x0050, code lost:
    
        if (((m.C0540b) r7).hasNext() != false) goto L28;
     */
    /* JADX WARN: Code restructure failed: missing block: B:27:0x0052, code lost:
    
        return true;
     */
    /* JADX WARN: Code restructure failed: missing block: B:28:0x0053, code lost:
    
        return false;
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final boolean equals(java.lang.Object r7) {
        /*
            r6 = this;
            r0 = 1
            if (r7 != r6) goto L4
            return r0
        L4:
            boolean r1 = r7 instanceof m.C0544f
            r2 = 0
            if (r1 != 0) goto La
            return r2
        La:
            m.f r7 = (m.C0544f) r7
            int r1 = r6.f5761d
            int r3 = r7.f5761d
            if (r1 == r3) goto L13
            return r2
        L13:
            java.util.Iterator r1 = r6.iterator()
            java.util.Iterator r7 = r7.iterator()
        L1b:
            r3 = r1
            m.b r3 = (m.C0540b) r3
            boolean r4 = r3.hasNext()
            if (r4 == 0) goto L44
            r4 = r7
            m.b r4 = (m.C0540b) r4
            boolean r5 = r4.hasNext()
            if (r5 == 0) goto L44
            java.lang.Object r3 = r3.next()
            java.util.Map$Entry r3 = (java.util.Map.Entry) r3
            java.lang.Object r4 = r4.next()
            if (r3 != 0) goto L3b
            if (r4 != 0) goto L43
        L3b:
            if (r3 == 0) goto L1b
            boolean r3 = r3.equals(r4)
            if (r3 != 0) goto L1b
        L43:
            return r2
        L44:
            boolean r1 = r3.hasNext()
            if (r1 != 0) goto L53
            m.b r7 = (m.C0540b) r7
            boolean r7 = r7.hasNext()
            if (r7 != 0) goto L53
            return r0
        L53:
            return r2
        */
        throw new UnsupportedOperationException("Method not decompiled: m.C0544f.equals(java.lang.Object):boolean");
    }

    public C0541c f(Object obj) {
        C0541c c0541c = this.f5758a;
        while (c0541c != null && !c0541c.f5751a.equals(obj)) {
            c0541c = c0541c.f5753c;
        }
        return c0541c;
    }

    public Object g(Object obj) {
        C0541c c0541cF = f(obj);
        if (c0541cF == null) {
            return null;
        }
        this.f5761d--;
        WeakHashMap weakHashMap = this.f5760c;
        if (!weakHashMap.isEmpty()) {
            Iterator it = weakHashMap.keySet().iterator();
            while (it.hasNext()) {
                ((AbstractC0543e) it.next()).a(c0541cF);
            }
        }
        C0541c c0541c = c0541cF.f5754d;
        if (c0541c != null) {
            c0541c.f5753c = c0541cF.f5753c;
        } else {
            this.f5758a = c0541cF.f5753c;
        }
        C0541c c0541c2 = c0541cF.f5753c;
        if (c0541c2 != null) {
            c0541c2.f5754d = c0541c;
        } else {
            this.f5759b = c0541c;
        }
        c0541cF.f5753c = null;
        c0541cF.f5754d = null;
        return c0541cF.f5752b;
    }

    public final int hashCode() {
        Iterator it = iterator();
        int iHashCode = 0;
        while (true) {
            C0540b c0540b = (C0540b) it;
            if (!c0540b.hasNext()) {
                return iHashCode;
            }
            iHashCode += ((Map.Entry) c0540b.next()).hashCode();
        }
    }

    @Override // java.lang.Iterable
    public final Iterator iterator() {
        C0540b c0540b = new C0540b(this.f5758a, this.f5759b, 0);
        this.f5760c.put(c0540b, Boolean.FALSE);
        return c0540b;
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder("[");
        Iterator it = iterator();
        while (true) {
            C0540b c0540b = (C0540b) it;
            if (!c0540b.hasNext()) {
                sb.append("]");
                return sb.toString();
            }
            sb.append(((Map.Entry) c0540b.next()).toString());
            if (c0540b.hasNext()) {
                sb.append(", ");
            }
        }
    }
}
