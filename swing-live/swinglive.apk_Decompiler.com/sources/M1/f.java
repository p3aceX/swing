package M1;

import java.util.Comparator;

/* JADX INFO: loaded from: classes.dex */
public final class f implements Comparator {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f1083a;

    public /* synthetic */ f(int i4) {
        this.f1083a = i4;
    }

    /* JADX WARN: Code restructure failed: missing block: B:13:0x001b, code lost:
    
        if (r0 == null) goto L19;
     */
    /* JADX WARN: Code restructure failed: missing block: B:17:0x0024, code lost:
    
        if (r0 != false) goto L18;
     */
    /* JADX WARN: Code restructure failed: missing block: B:18:0x0026, code lost:
    
        return -1;
     */
    /* JADX WARN: Code restructure failed: missing block: B:33:?, code lost:
    
        return 1;
     */
    @Override // java.util.Comparator
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final int compare(java.lang.Object r6, java.lang.Object r7) {
        /*
            r5 = this;
            int r0 = r5.f1083a
            switch(r0) {
                case 0: goto L3c;
                default: goto L5;
            }
        L5:
            X.i r6 = (X.C0178i) r6
            X.i r7 = (X.C0178i) r7
            androidx.recyclerview.widget.RecyclerView r0 = r6.f2353d
            r1 = 0
            r2 = 1
            if (r0 != 0) goto L11
            r3 = r2
            goto L12
        L11:
            r3 = r1
        L12:
            androidx.recyclerview.widget.RecyclerView r4 = r7.f2353d
            if (r4 != 0) goto L18
            r4 = r2
            goto L19
        L18:
            r4 = r1
        L19:
            if (r3 == r4) goto L1e
            if (r0 != 0) goto L26
            goto L28
        L1e:
            boolean r0 = r6.f2350a
            boolean r3 = r7.f2350a
            if (r0 == r3) goto L2a
            if (r0 == 0) goto L28
        L26:
            r1 = -1
            goto L3b
        L28:
            r1 = r2
            goto L3b
        L2a:
            int r0 = r7.f2351b
            int r2 = r6.f2351b
            int r0 = r0 - r2
            if (r0 == 0) goto L33
            r1 = r0
            goto L3b
        L33:
            int r6 = r6.f2352c
            int r7 = r7.f2352c
            int r6 = r6 - r7
            if (r6 == 0) goto L3b
            r1 = r6
        L3b:
            return r1
        L3c:
            android.util.Size r7 = (android.util.Size) r7
            int r7 = r7.getHeight()
            java.lang.Integer r7 = java.lang.Integer.valueOf(r7)
            android.util.Size r6 = (android.util.Size) r6
            int r6 = r6.getHeight()
            java.lang.Integer r6 = java.lang.Integer.valueOf(r6)
            if (r7 != r6) goto L54
            r6 = 0
            goto L58
        L54:
            int r6 = r7.compareTo(r6)
        L58:
            return r6
        */
        throw new UnsupportedOperationException("Method not decompiled: M1.f.compare(java.lang.Object, java.lang.Object):int");
    }
}
