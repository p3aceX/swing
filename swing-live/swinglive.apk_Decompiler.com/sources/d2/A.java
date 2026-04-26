package D2;

import android.view.KeyCharacterMap;

/* JADX INFO: loaded from: classes.dex */
public final class A {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f153a = 0;

    public Character a(int i4) {
        char c5 = (char) i4;
        if ((Integer.MIN_VALUE & i4) != 0) {
            int i5 = i4 & com.google.android.gms.common.api.f.API_PRIORITY_OTHER;
            int i6 = this.f153a;
            if (i6 != 0) {
                this.f153a = KeyCharacterMap.getDeadChar(i6, i5);
            } else {
                this.f153a = i5;
            }
        } else {
            int i7 = this.f153a;
            if (i7 != 0) {
                int deadChar = KeyCharacterMap.getDeadChar(i7, i4);
                if (deadChar > 0) {
                    c5 = (char) deadChar;
                }
                this.f153a = 0;
            }
        }
        return Character.valueOf(c5);
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0014  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public java.io.Serializable b(e1.AbstractC0367g r6, A3.c r7) throws java.io.IOException {
        /*
            r5 = this;
            r0 = 1
            boolean r1 = r7 instanceof e2.s
            if (r1 == 0) goto L14
            r1 = r7
            e2.s r1 = (e2.s) r1
            int r2 = r1.f4208c
            r3 = -2147483648(0xffffffff80000000, float:-0.0)
            r4 = r2 & r3
            if (r4 == 0) goto L14
            int r2 = r2 - r3
            r1.f4208c = r2
            goto L19
        L14:
            e2.s r1 = new e2.s
            r1.<init>(r5, r7)
        L19:
            java.lang.Object r7 = r1.f4206a
            z3.a r2 = z3.EnumC0789a.f6999a
            int r3 = r1.f4208c
            java.lang.String r4 = "Handshake"
            if (r3 == 0) goto L31
            if (r3 != r0) goto L29
            e1.AbstractC0367g.M(r7)
            goto L42
        L29:
            java.lang.IllegalStateException r6 = new java.lang.IllegalStateException
            java.lang.String r7 = "call to 'resume' before 'invoke' with coroutine"
            r6.<init>(r7)
            throw r6
        L31:
            e1.AbstractC0367g.M(r7)
            java.lang.String r7 = "reading S0"
            android.util.Log.i(r4, r7)
            r1.f4208c = r0
            java.lang.Object r7 = r6.B(r1)
            if (r7 != r2) goto L42
            return r2
        L42:
            java.lang.Number r7 = (java.lang.Number) r7
            int r6 = r7.intValue()
            r7 = 3
            if (r6 == r7) goto L5e
            r7 = 72
            if (r6 != r7) goto L50
            goto L5e
        L50:
            java.io.IOException r7 = new java.io.IOException
            java.lang.String r0 = "Handshake error, unexpected "
            java.lang.String r1 = " S0 received"
            java.lang.String r6 = B1.a.l(r0, r6, r1)
            r7.<init>(r6)
            throw r7
        L5e:
            java.lang.String r7 = "read S0 successful"
            android.util.Log.i(r4, r7)
            byte r6 = (byte) r6
            byte[] r7 = new byte[r0]
            r0 = 0
            r7[r0] = r6
            return r7
        */
        throw new UnsupportedOperationException("Method not decompiled: D2.A.b(e1.g, A3.c):java.io.Serializable");
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Type inference failed for: r6v0, types: [e1.g] */
    /* JADX WARN: Type inference failed for: r6v2 */
    /* JADX WARN: Type inference failed for: r6v3, types: [java.io.Serializable] */
    /* JADX WARN: Type inference failed for: r6v6 */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public java.io.Serializable c(e1.AbstractC0367g r6, A3.c r7) {
        /*
            r5 = this;
            boolean r0 = r7 instanceof e2.t
            if (r0 == 0) goto L13
            r0 = r7
            e2.t r0 = (e2.t) r0
            int r1 = r0.f4212d
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f4212d = r1
            goto L18
        L13:
            e2.t r0 = new e2.t
            r0.<init>(r5, r7)
        L18:
            java.lang.Object r7 = r0.f4210b
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f4212d
            java.lang.String r3 = "Handshake"
            r4 = 1
            if (r2 == 0) goto L33
            if (r2 != r4) goto L2b
            byte[] r6 = r0.f4209a
            e1.AbstractC0367g.M(r7)
            goto L4b
        L2b:
            java.lang.IllegalStateException r6 = new java.lang.IllegalStateException
            java.lang.String r7 = "call to 'resume' before 'invoke' with coroutine"
            r6.<init>(r7)
            throw r6
        L33:
            e1.AbstractC0367g.M(r7)
            java.lang.String r7 = "reading S1"
            android.util.Log.i(r3, r7)
            r7 = 1536(0x600, float:2.152E-42)
            byte[] r7 = new byte[r7]
            r0.f4209a = r7
            r0.f4212d = r4
            java.lang.Object r6 = r6.I(r7, r0)
            if (r6 != r1) goto L4a
            return r1
        L4a:
            r6 = r7
        L4b:
            java.lang.String r7 = "read S1 successful"
            android.util.Log.i(r3, r7)
            return r6
        */
        throw new UnsupportedOperationException("Method not decompiled: D2.A.c(e1.g, A3.c):java.io.Serializable");
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Type inference failed for: r6v2 */
    /* JADX WARN: Type inference failed for: r6v3, types: [byte[], java.io.Serializable] */
    /* JADX WARN: Type inference failed for: r6v6 */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public java.io.Serializable d(e1.AbstractC0367g r6, byte[] r7, A3.c r8) {
        /*
            r5 = this;
            boolean r0 = r8 instanceof e2.u
            if (r0 == 0) goto L13
            r0 = r8
            e2.u r0 = (e2.u) r0
            int r1 = r0.e
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.e = r1
            goto L18
        L13:
            e2.u r0 = new e2.u
            r0.<init>(r5, r8)
        L18:
            java.lang.Object r8 = r0.f4215c
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.e
            r3 = 1
            java.lang.String r4 = "Handshake"
            if (r2 == 0) goto L35
            if (r2 != r3) goto L2d
            byte[] r6 = r0.f4214b
            byte[] r7 = r0.f4213a
            e1.AbstractC0367g.M(r8)
            goto L4f
        L2d:
            java.lang.IllegalStateException r6 = new java.lang.IllegalStateException
            java.lang.String r7 = "call to 'resume' before 'invoke' with coroutine"
            r6.<init>(r7)
            throw r6
        L35:
            e1.AbstractC0367g.M(r8)
            java.lang.String r8 = "reading S2"
            android.util.Log.i(r4, r8)
            r8 = 1536(0x600, float:2.152E-42)
            byte[] r8 = new byte[r8]
            r0.f4213a = r7
            r0.f4214b = r8
            r0.e = r3
            java.lang.Object r6 = r6.I(r8, r0)
            if (r6 != r1) goto L4e
            return r1
        L4e:
            r6 = r8
        L4f:
            boolean r7 = java.util.Arrays.equals(r6, r7)
            if (r7 != 0) goto L5a
            java.lang.String r7 = "S2 content is different that C1"
            android.util.Log.e(r4, r7)
        L5a:
            java.lang.String r7 = "read S2 successful"
            android.util.Log.i(r4, r7)
            return r6
        */
        throw new UnsupportedOperationException("Method not decompiled: D2.A.d(e1.g, byte[], A3.c):java.io.Serializable");
    }

    /* JADX WARN: Code restructure failed: missing block: B:43:0x00da, code lost:
    
        if (d(r2, r6, r0) != r1) goto L45;
     */
    /* JADX WARN: Removed duplicated region for block: B:19:0x005f A[PHI: r6 r7
      0x005f: PHI (r6v3 e1.g) = (r6v1 e1.g), (r6v6 e1.g) binds: [B:25:0x007f, B:18:0x005a] A[DONT_GENERATE, DONT_INLINE]
      0x005f: PHI (r7v6 java.lang.Object) = (r7v5 java.lang.Object), (r7v1 java.lang.Object) binds: [B:25:0x007f, B:18:0x005a] A[DONT_GENERATE, DONT_INLINE]] */
    /* JADX WARN: Removed duplicated region for block: B:30:0x0093 A[PHI: r2 r6
      0x0093: PHI (r2v2 e1.g) = (r2v1 e1.g), (r2v3 e1.g) binds: [B:28:0x0090, B:17:0x0052] A[DONT_GENERATE, DONT_INLINE]
      0x0093: PHI (r6v7 byte[]) = (r6v5 byte[]), (r6v8 byte[]) binds: [B:28:0x0090, B:17:0x0052] A[DONT_GENERATE, DONT_INLINE]] */
    /* JADX WARN: Removed duplicated region for block: B:33:0x00a1 A[PHI: r2 r6
      0x00a1: PHI (r2v4 e1.g) = (r2v2 e1.g), (r2v5 e1.g) binds: [B:31:0x009e, B:16:0x004a] A[DONT_GENERATE, DONT_INLINE]
      0x00a1: PHI (r6v9 byte[]) = (r6v7 byte[]), (r6v10 byte[]) binds: [B:31:0x009e, B:16:0x004a] A[DONT_GENERATE, DONT_INLINE]] */
    /* JADX WARN: Removed duplicated region for block: B:36:0x00af A[PHI: r2 r6 r7
      0x00af: PHI (r2v6 e1.g) = (r2v4 e1.g), (r2v7 e1.g) binds: [B:34:0x00ac, B:15:0x0041] A[DONT_GENERATE, DONT_INLINE]
      0x00af: PHI (r6v11 byte[]) = (r6v9 byte[]), (r6v12 byte[]) binds: [B:34:0x00ac, B:15:0x0041] A[DONT_GENERATE, DONT_INLINE]
      0x00af: PHI (r7v13 java.lang.Object) = (r7v12 java.lang.Object), (r7v1 java.lang.Object) binds: [B:34:0x00ac, B:15:0x0041] A[DONT_GENERATE, DONT_INLINE]] */
    /* JADX WARN: Removed duplicated region for block: B:39:0x00bf A[PHI: r2 r6
      0x00bf: PHI (r2v8 e1.g) = (r2v6 e1.g), (r2v9 e1.g) binds: [B:37:0x00bc, B:14:0x0038] A[DONT_GENERATE, DONT_INLINE]
      0x00bf: PHI (r6v13 byte[]) = (r6v11 byte[]), (r6v14 byte[]) binds: [B:37:0x00bc, B:14:0x0038] A[DONT_GENERATE, DONT_INLINE]] */
    /* JADX WARN: Removed duplicated region for block: B:42:0x00cd A[PHI: r2 r6
      0x00cd: PHI (r2v10 e1.g) = (r2v8 e1.g), (r2v11 e1.g) binds: [B:40:0x00ca, B:13:0x002f] A[DONT_GENERATE, DONT_INLINE]
      0x00cd: PHI (r6v15 byte[]) = (r6v13 byte[]), (r6v17 byte[]) binds: [B:40:0x00ca, B:13:0x002f] A[DONT_GENERATE, DONT_INLINE]] */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public java.lang.Object e(e1.AbstractC0367g r6, A3.c r7) {
        /*
            Method dump skipped, instruction units count: 246
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: D2.A.e(e1.g, A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public java.lang.Object f(e1.AbstractC0367g r6, A3.c r7) {
        /*
            r5 = this;
            boolean r0 = r7 instanceof e2.w
            if (r0 == 0) goto L13
            r0 = r7
            e2.w r0 = (e2.w) r0
            int r1 = r0.f4223c
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f4223c = r1
            goto L18
        L13:
            e2.w r0 = new e2.w
            r0.<init>(r5, r7)
        L18:
            java.lang.Object r7 = r0.f4221a
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f4223c
            java.lang.String r3 = "Handshake"
            r4 = 1
            if (r2 == 0) goto L31
            if (r2 != r4) goto L29
            e1.AbstractC0367g.M(r7)
            goto L43
        L29:
            java.lang.IllegalStateException r6 = new java.lang.IllegalStateException
            java.lang.String r7 = "call to 'resume' before 'invoke' with coroutine"
            r6.<init>(r7)
            throw r6
        L31:
            e1.AbstractC0367g.M(r7)
            java.lang.String r7 = "writing C0"
            android.util.Log.i(r3, r7)
            r0.f4223c = r4
            r7 = 3
            java.lang.Object r6 = r6.Q(r7, r0)
            if (r6 != r1) goto L43
            return r1
        L43:
            java.lang.String r6 = "C0 write successful"
            android.util.Log.i(r3, r6)
            w3.i r6 = w3.i.f6729a
            return r6
        */
        throw new UnsupportedOperationException("Method not decompiled: D2.A.f(e1.g, A3.c):java.lang.Object");
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0018  */
    /* JADX WARN: Type inference failed for: r13v0, types: [e1.g] */
    /* JADX WARN: Type inference failed for: r13v2 */
    /* JADX WARN: Type inference failed for: r13v3, types: [java.io.Serializable] */
    /* JADX WARN: Type inference failed for: r13v6 */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public java.io.Serializable g(e1.AbstractC0367g r13, A3.c r14) {
        /*
            r12 = this;
            r0 = 0
            r1 = 8
            r2 = 4
            r3 = 1
            boolean r4 = r14 instanceof e2.x
            if (r4 == 0) goto L18
            r4 = r14
            e2.x r4 = (e2.x) r4
            int r5 = r4.f4227d
            r6 = -2147483648(0xffffffff80000000, float:-0.0)
            r7 = r5 & r6
            if (r7 == 0) goto L18
            int r5 = r5 - r6
            r4.f4227d = r5
            goto L1d
        L18:
            e2.x r4 = new e2.x
            r4.<init>(r12, r14)
        L1d:
            java.lang.Object r14 = r4.f4225b
            z3.a r5 = z3.EnumC0789a.f6999a
            int r6 = r4.f4227d
            java.lang.String r7 = "Handshake"
            if (r6 == 0) goto L38
            if (r6 != r3) goto L30
            byte[] r13 = r4.f4224a
            e1.AbstractC0367g.M(r14)
            goto Lb8
        L30:
            java.lang.IllegalStateException r13 = new java.lang.IllegalStateException
            java.lang.String r14 = "call to 'resume' before 'invoke' with coroutine"
            r13.<init>(r14)
            throw r13
        L38:
            e1.AbstractC0367g.M(r14)
            java.lang.String r14 = "writing C1"
            android.util.Log.i(r7, r14)
            r14 = 1536(0x600, float:2.152E-42)
            byte[] r14 = new byte[r14]
            long r8 = android.os.SystemClock.elapsedRealtime()
            r6 = 1000(0x3e8, float:1.401E-42)
            long r10 = (long) r6
            long r8 = r8 / r10
            int r6 = (int) r8
            r12.f153a = r6
            java.lang.StringBuilder r8 = new java.lang.StringBuilder
            java.lang.String r9 = "writing time "
            r8.<init>(r9)
            r8.append(r6)
            java.lang.String r6 = " to c1"
            r8.append(r6)
            java.lang.String r6 = r8.toString()
            android.util.Log.i(r7, r6)
            int r6 = r12.f153a
            int r8 = r6 >>> 24
            byte r8 = (byte) r8
            int r9 = r6 >>> 16
            byte r9 = (byte) r9
            int r10 = r6 >>> 8
            byte r10 = (byte) r10
            byte r6 = (byte) r6
            byte[] r11 = new byte[r2]
            r11[r0] = r8
            r11[r3] = r9
            r8 = 2
            r11[r8] = r10
            r8 = 3
            r11[r8] = r6
            java.lang.System.arraycopy(r11, r0, r14, r0, r2)
            java.lang.String r6 = "writing zero to c1"
            android.util.Log.i(r7, r6)
            byte[] r6 = new byte[r2]
            r6 = {x00c0: FILL_ARRAY_DATA , data: [0, 0, 0, 0} // fill-array
            java.lang.System.arraycopy(r6, r0, r14, r2, r2)
            java.lang.String r2 = "writing random to c1"
            android.util.Log.i(r7, r2)
            K3.a r2 = K3.d.f859a
            r2 = 1528(0x5f8, float:2.141E-42)
            byte[] r6 = new byte[r2]
            r8 = r0
        L99:
            int r9 = r8 + 1
            K3.a r10 = K3.d.f859a
            int r10 = r10.b()
            byte r10 = (byte) r10
            byte r10 = (byte) r10
            r6[r8] = r10
            r8 = 1527(0x5f7, float:2.14E-42)
            if (r9 <= r8) goto Lbe
            java.lang.System.arraycopy(r6, r0, r14, r1, r2)
            r4.f4224a = r14
            r4.f4227d = r3
            java.lang.Object r13 = r13.S(r14, r4)
            if (r13 != r5) goto Lb7
            return r5
        Lb7:
            r13 = r14
        Lb8:
            java.lang.String r14 = "C1 write successful"
            android.util.Log.i(r7, r14)
            return r13
        Lbe:
            r8 = r9
            goto L99
        */
        throw new UnsupportedOperationException("Method not decompiled: D2.A.g(e1.g, A3.c):java.io.Serializable");
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public java.lang.Object h(e1.AbstractC0367g r6, byte[] r7, A3.c r8) {
        /*
            r5 = this;
            boolean r0 = r8 instanceof e2.y
            if (r0 == 0) goto L13
            r0 = r8
            e2.y r0 = (e2.y) r0
            int r1 = r0.f4230c
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f4230c = r1
            goto L18
        L13:
            e2.y r0 = new e2.y
            r0.<init>(r5, r8)
        L18:
            java.lang.Object r8 = r0.f4228a
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f4230c
            java.lang.String r3 = "Handshake"
            r4 = 1
            if (r2 == 0) goto L31
            if (r2 != r4) goto L29
            e1.AbstractC0367g.M(r8)
            goto L42
        L29:
            java.lang.IllegalStateException r6 = new java.lang.IllegalStateException
            java.lang.String r7 = "call to 'resume' before 'invoke' with coroutine"
            r6.<init>(r7)
            throw r6
        L31:
            e1.AbstractC0367g.M(r8)
            java.lang.String r8 = "writing C2"
            android.util.Log.i(r3, r8)
            r0.f4230c = r4
            java.lang.Object r6 = r6.S(r7, r0)
            if (r6 != r1) goto L42
            return r1
        L42:
            java.lang.String r6 = "C2 write successful"
            android.util.Log.i(r3, r6)
            w3.i r6 = w3.i.f6729a
            return r6
        */
        throw new UnsupportedOperationException("Method not decompiled: D2.A.h(e1.g, byte[], A3.c):java.lang.Object");
    }
}
