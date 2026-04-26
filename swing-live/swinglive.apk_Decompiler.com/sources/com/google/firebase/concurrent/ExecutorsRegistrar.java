package com.google.firebase.concurrent;

import A.C0003c;
import android.annotation.SuppressLint;
import com.google.firebase.components.ComponentRegistrar;
import e1.AbstractC0367g;
import h1.InterfaceC0411a;
import h1.b;
import h1.c;
import h1.d;
import io.flutter.plugin.platform.f;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.concurrent.Executor;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.ScheduledExecutorService;
import l1.C0522a;
import l1.e;
import l1.n;
import l1.r;

/* JADX INFO: loaded from: classes.dex */
@SuppressLint({"ThreadPoolCreation"})
public class ExecutorsRegistrar implements ComponentRegistrar {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final n f3865a = new n(new e(2));

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final n f3866b = new n(new e(3));

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final n f3867c = new n(new e(4));

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final n f3868d = new n(new e(5));

    @Override // com.google.firebase.components.ComponentRegistrar
    public final List getComponents() {
        r rVar = new r(InterfaceC0411a.class, ScheduledExecutorService.class);
        r[] rVarArr = {new r(InterfaceC0411a.class, ExecutorService.class), new r(InterfaceC0411a.class, Executor.class)};
        HashSet hashSet = new HashSet();
        HashSet hashSet2 = new HashSet();
        HashSet hashSet3 = new HashSet();
        hashSet.add(rVar);
        for (r rVar2 : rVarArr) {
            AbstractC0367g.a(rVar2, "Null interface");
        }
        Collections.addAll(hashSet, rVarArr);
        C0522a c0522a = new C0522a(new HashSet(hashSet), new HashSet(hashSet2), 0, new C0003c(19), hashSet3);
        r rVar3 = new r(b.class, ScheduledExecutorService.class);
        r[] rVarArr2 = {new r(b.class, ExecutorService.class), new r(b.class, Executor.class)};
        HashSet hashSet4 = new HashSet();
        HashSet hashSet5 = new HashSet();
        HashSet hashSet6 = new HashSet();
        hashSet4.add(rVar3);
        for (r rVar4 : rVarArr2) {
            AbstractC0367g.a(rVar4, "Null interface");
        }
        Collections.addAll(hashSet4, rVarArr2);
        C0522a c0522a2 = new C0522a(new HashSet(hashSet4), new HashSet(hashSet5), 0, new C0003c(20), hashSet6);
        r rVar5 = new r(c.class, ScheduledExecutorService.class);
        r[] rVarArr3 = {new r(c.class, ExecutorService.class), new r(c.class, Executor.class)};
        HashSet hashSet7 = new HashSet();
        HashSet hashSet8 = new HashSet();
        HashSet hashSet9 = new HashSet();
        hashSet7.add(rVar5);
        for (r rVar6 : rVarArr3) {
            AbstractC0367g.a(rVar6, "Null interface");
        }
        Collections.addAll(hashSet7, rVarArr3);
        C0522a c0522a3 = new C0522a(new HashSet(hashSet7), new HashSet(hashSet8), 0, new C0003c(21), hashSet9);
        f fVarA = C0522a.a(new r(d.class, Executor.class));
        fVarA.f4629d = new C0003c(22);
        return Arrays.asList(c0522a, c0522a2, c0522a3, fVarA.b());
    }
}
