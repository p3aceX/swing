package io.ktor.utils.io;

import Q3.y0;
import y3.InterfaceC0767h;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public abstract class z {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final D f5030a = new D(null);

    public static final void a(A a5) {
        J3.i.e(a5, "<this>");
        a5.a().a(null);
    }

    public static final void b(v vVar, Throwable th) {
        J3.i.e(vVar, "<this>");
        vVar.t(th);
    }

    /* JADX WARN: Removed duplicated region for block: B:8:0x0021  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object c(io.ktor.utils.io.v r3, A3.c r4) {
        /*
            java.lang.String r0 = "<this>"
            J3.i.e(r3, r0)
            java.lang.Throwable r1 = r3.o()
            if (r1 != 0) goto L2b
            boolean r1 = r3.u()
            w3.i r2 = w3.i.f6729a
            if (r1 != 0) goto L21
            Z3.a r1 = r3.h()
            J3.i.e(r1, r0)
            long r0 = r1.f2603c
            int r0 = (int) r0
            r1 = 1048576(0x100000, float:1.469368E-39)
            if (r0 < r1) goto L2a
        L21:
            java.lang.Object r3 = r3.n(r4)
            z3.a r4 = z3.EnumC0789a.f6999a
            if (r3 != r4) goto L2a
            return r3
        L2a:
            return r2
        L2b:
            throw r1
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.utils.io.z.c(io.ktor.utils.io.v, A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object d(io.ktor.utils.io.o r5, java.nio.ByteBuffer r6, A3.c r7) {
        /*
            boolean r0 = r7 instanceof io.ktor.utils.io.u
            if (r0 == 0) goto L13
            r0 = r7
            io.ktor.utils.io.u r0 = (io.ktor.utils.io.u) r0
            int r1 = r0.f5020d
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f5020d = r1
            goto L18
        L13:
            io.ktor.utils.io.u r0 = new io.ktor.utils.io.u
            r0.<init>(r7)
        L18:
            java.lang.Object r7 = r0.f5019c
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f5020d
            r3 = 1
            r4 = -1
            if (r2 == 0) goto L34
            if (r2 != r3) goto L2c
            java.nio.ByteBuffer r6 = r0.f5018b
            io.ktor.utils.io.m r5 = r0.f5017a
            e1.AbstractC0367g.M(r7)
            goto L5e
        L2c:
            java.lang.IllegalStateException r5 = new java.lang.IllegalStateException
            java.lang.String r6 = "call to 'resume' before 'invoke' with coroutine"
            r5.<init>(r6)
            throw r5
        L34:
            e1.AbstractC0367g.M(r7)
            io.ktor.utils.io.m r5 = (io.ktor.utils.io.C0449m) r5
            boolean r7 = r5.f()
            if (r7 == 0) goto L45
            java.lang.Integer r5 = new java.lang.Integer
            r5.<init>(r4)
            return r5
        L45:
            Z3.h r7 = r5.e()
            Z3.a r7 = (Z3.a) r7
            boolean r7 = r7.w()
            if (r7 == 0) goto L5e
            r0.f5017a = r5
            r0.f5018b = r6
            r0.f5020d = r3
            java.lang.Object r7 = r5.a(r3, r0)
            if (r7 != r1) goto L5e
            return r1
        L5e:
            boolean r7 = r5.f()
            if (r7 == 0) goto L6a
            java.lang.Integer r5 = new java.lang.Integer
            r5.<init>(r4)
            return r5
        L6a:
            Z3.h r5 = r5.e()
            int r5 = Z3.i.c(r5, r6)
            java.lang.Integer r6 = new java.lang.Integer
            r6.<init>(r5)
            return r6
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.utils.io.z.d(io.ktor.utils.io.o, java.nio.ByteBuffer, A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object e(io.ktor.utils.io.o r5, A3.c r6) {
        /*
            boolean r0 = r6 instanceof io.ktor.utils.io.p
            if (r0 == 0) goto L13
            r0 = r6
            io.ktor.utils.io.p r0 = (io.ktor.utils.io.p) r0
            int r1 = r0.f5000c
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f5000c = r1
            goto L18
        L13:
            io.ktor.utils.io.p r0 = new io.ktor.utils.io.p
            r0.<init>(r6)
        L18:
            java.lang.Object r6 = r0.f4999b
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f5000c
            r3 = 1
            if (r2 == 0) goto L31
            if (r2 != r3) goto L29
            Z3.a r5 = r0.f4998a
            e1.AbstractC0367g.M(r6)
            goto L50
        L29:
            java.lang.IllegalStateException r5 = new java.lang.IllegalStateException
            java.lang.String r6 = "call to 'resume' before 'invoke' with coroutine"
            r5.<init>(r6)
            throw r5
        L31:
            e1.AbstractC0367g.M(r6)
            io.ktor.utils.io.m r5 = (io.ktor.utils.io.C0449m) r5
            Z3.h r6 = r5.e()
            Z3.a r6 = (Z3.a) r6
            boolean r2 = r6.w()
            if (r2 == 0) goto L62
            r0.f4998a = r6
            r0.f5000c = r3
            java.lang.Object r5 = r5.a(r3, r0)
            if (r5 != r1) goto L4d
            return r1
        L4d:
            r4 = r6
            r6 = r5
            r5 = r4
        L50:
            java.lang.Boolean r6 = (java.lang.Boolean) r6
            boolean r6 = r6.booleanValue()
            if (r6 == 0) goto L5a
            r6 = r5
            goto L62
        L5a:
            java.io.EOFException r5 = new java.io.EOFException
            java.lang.String r6 = "Not enough data available"
            r5.<init>(r6)
            throw r5
        L62:
            byte r5 = r6.readByte()
            java.lang.Byte r5 = java.lang.Byte.valueOf(r5)
            return r5
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.utils.io.z.e(io.ktor.utils.io.o, A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:23:0x0053  */
    /* JADX WARN: Removed duplicated region for block: B:32:0x007a  */
    /* JADX WARN: Removed duplicated region for block: B:33:0x0095  */
    /* JADX WARN: Removed duplicated region for block: B:35:0x009b  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:24:0x005d -> B:30:0x0074). Please report as a decompilation issue!!! */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:28:0x0070 -> B:29:0x0072). Please report as a decompilation issue!!! */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object f(io.ktor.utils.io.C0449m r8, byte[] r9, int r10, A3.c r11) throws java.io.EOFException {
        /*
            boolean r0 = r11 instanceof io.ktor.utils.io.q
            if (r0 == 0) goto L13
            r0 = r11
            io.ktor.utils.io.q r0 = (io.ktor.utils.io.q) r0
            int r1 = r0.f5005f
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f5005f = r1
            goto L18
        L13:
            io.ktor.utils.io.q r0 = new io.ktor.utils.io.q
            r0.<init>(r11)
        L18:
            java.lang.Object r11 = r0.e
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f5005f
            r3 = 1
            java.lang.String r4 = "Channel is already closed"
            if (r2 == 0) goto L39
            if (r2 != r3) goto L31
            int r8 = r0.f5004d
            int r9 = r0.f5003c
            byte[] r10 = r0.f5002b
            io.ktor.utils.io.m r2 = r0.f5001a
            e1.AbstractC0367g.M(r11)
            goto L72
        L31:
            java.lang.IllegalStateException r8 = new java.lang.IllegalStateException
            java.lang.String r9 = "call to 'resume' before 'invoke' with coroutine"
            r8.<init>(r9)
            throw r8
        L39:
            e1.AbstractC0367g.M(r11)
            if (r10 <= 0) goto L4b
            boolean r11 = r8.f()
            if (r11 != 0) goto L45
            goto L4b
        L45:
            java.io.EOFException r8 = new java.io.EOFException
            r8.<init>(r4)
            throw r8
        L4b:
            r11 = 0
            r7 = r9
            r9 = r8
            r8 = r11
            r11 = r10
            r10 = r7
        L51:
            if (r8 >= r11) goto L9b
            Z3.h r2 = r9.e()
            Z3.a r2 = (Z3.a) r2
            boolean r2 = r2.w()
            if (r2 == 0) goto L74
            r0.f5001a = r9
            r0.f5002b = r10
            r0.f5003c = r11
            r0.f5004d = r8
            r0.f5005f = r3
            java.lang.Object r2 = r9.a(r3, r0)
            if (r2 != r1) goto L70
            return r1
        L70:
            r2 = r9
            r9 = r11
        L72:
            r11 = r9
            r9 = r2
        L74:
            boolean r2 = r9.f()
            if (r2 != 0) goto L95
            int r2 = r11 - r8
            Z3.h r5 = r9.e()
            long r5 = u3.AbstractC0692a.a(r5)
            int r5 = (int) r5
            int r2 = java.lang.Math.min(r2, r5)
            Z3.h r5 = r9.e()
            int r2 = r2 + r8
            Z3.a r5 = (Z3.a) r5
            Z3.i.f(r5, r10, r8, r2)
            r8 = r2
            goto L51
        L95:
            java.io.EOFException r8 = new java.io.EOFException
            r8.<init>(r4)
            throw r8
        L9b:
            w3.i r8 = w3.i.f6729a
            return r8
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.utils.io.z.f(io.ktor.utils.io.m, byte[], int, A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:17:0x0047  */
    /* JADX WARN: Removed duplicated region for block: B:26:0x006e  */
    /* JADX WARN: Removed duplicated region for block: B:43:0x00f8 A[RETURN] */
    /* JADX WARN: Removed duplicated region for block: B:44:0x00f9  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:18:0x0054 -> B:24:0x0067). Please report as a decompilation issue!!! */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:22:0x0065 -> B:23:0x0066). Please report as a decompilation issue!!! */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object g(io.ktor.utils.io.o r11, int r12, A3.c r13) {
        /*
            Method dump skipped, instruction units count: 277
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.utils.io.z.g(io.ktor.utils.io.o, int, A3.c):java.lang.Object");
    }

    public static final J h(Q3.D d5, InterfaceC0767h interfaceC0767h, C0449m c0449m, I3.p pVar) {
        J3.i.e(interfaceC0767h, "coroutineContext");
        y0 y0VarS = Q3.F.s(d5, interfaceC0767h, new t(pVar, c0449m, null), 2);
        y0VarS.q(new n(c0449m, 1));
        return new J(new com.google.android.gms.common.internal.r(8, c0449m, new s(y0VarS, null)), y0VarS);
    }

    public static final Object i(v vVar, byte b5, A3.c cVar) {
        vVar.h().n(b5);
        Object objC = c(vVar, cVar);
        return objC == EnumC0789a.f6999a ? objC : w3.i.f6729a;
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0015  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object j(io.ktor.utils.io.v r16, Z3.h r17, A3.c r18) {
        /*
            r0 = r18
            boolean r1 = r0 instanceof io.ktor.utils.io.x
            if (r1 == 0) goto L15
            r1 = r0
            io.ktor.utils.io.x r1 = (io.ktor.utils.io.x) r1
            int r2 = r1.f5024d
            r3 = -2147483648(0xffffffff80000000, float:-0.0)
            r4 = r2 & r3
            if (r4 == 0) goto L15
            int r2 = r2 - r3
            r1.f5024d = r2
            goto L1a
        L15:
            io.ktor.utils.io.x r1 = new io.ktor.utils.io.x
            r1.<init>(r0)
        L1a:
            java.lang.Object r0 = r1.f5023c
            z3.a r2 = z3.EnumC0789a.f6999a
            int r3 = r1.f5024d
            r4 = 1
            if (r3 == 0) goto L39
            if (r3 != r4) goto L31
            Z3.h r3 = r1.f5022b
            io.ktor.utils.io.v r5 = r1.f5021a
            e1.AbstractC0367g.M(r0)
            r0 = r3
            r3 = r1
            r1 = r0
            r0 = r5
            goto L41
        L31:
            java.lang.IllegalStateException r0 = new java.lang.IllegalStateException
            java.lang.String r1 = "call to 'resume' before 'invoke' with coroutine"
            r0.<init>(r1)
            throw r0
        L39:
            e1.AbstractC0367g.M(r0)
            r0 = r16
            r3 = r1
            r1 = r17
        L41:
            boolean r5 = r1.w()
            if (r5 != 0) goto Lb5
            Z3.a r5 = r0.h()
            long r6 = u3.AbstractC0692a.a(r1)
            r5.getClass()
            r8 = 0
            int r10 = (r6 > r8 ? 1 : (r6 == r8 ? 0 : -1))
            if (r10 < 0) goto L98
            r10 = r6
        L59:
            int r12 = (r10 > r8 ? 1 : (r10 == r8 ? 0 : -1))
            if (r12 <= 0) goto L8b
            long r12 = r1.m(r5, r10)
            r14 = -1
            int r14 = (r12 > r14 ? 1 : (r12 == r14 ? 0 : -1))
            if (r14 == 0) goto L69
            long r10 = r10 - r12
            goto L59
        L69:
            java.io.EOFException r0 = new java.io.EOFException
            java.lang.StringBuilder r1 = new java.lang.StringBuilder
            java.lang.String r2 = "Source exhausted before reading "
            r1.<init>(r2)
            r1.append(r6)
            java.lang.String r2 = " bytes. Only "
            r1.append(r2)
            long r6 = r6 - r10
            r1.append(r6)
            java.lang.String r2 = " were read."
            r1.append(r2)
            java.lang.String r1 = r1.toString()
            r0.<init>(r1)
            throw r0
        L8b:
            r3.f5021a = r0
            r3.f5022b = r1
            r3.f5024d = r4
            java.lang.Object r5 = c(r0, r3)
            if (r5 != r2) goto L41
            return r2
        L98:
            java.lang.StringBuilder r0 = new java.lang.StringBuilder
            java.lang.String r1 = "byteCount ("
            r0.<init>(r1)
            r0.append(r6)
            java.lang.String r1 = ") < 0"
            r0.append(r1)
            java.lang.String r0 = r0.toString()
            java.lang.IllegalArgumentException r1 = new java.lang.IllegalArgumentException
            java.lang.String r0 = r0.toString()
            r1.<init>(r0)
            throw r1
        Lb5:
            w3.i r0 = w3.i.f6729a
            return r0
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.utils.io.z.j(io.ktor.utils.io.v, Z3.h, A3.c):java.lang.Object");
    }

    public static final L k(Q3.D d5, InterfaceC0767h interfaceC0767h, C0449m c0449m, I3.p pVar) {
        J3.i.e(interfaceC0767h, "coroutineContext");
        y0 y0VarS = Q3.F.s(d5, interfaceC0767h, new y(pVar, c0449m, null), 2);
        y0VarS.q(new n(c0449m, 2));
        return new L(c0449m, y0VarS);
    }
}
