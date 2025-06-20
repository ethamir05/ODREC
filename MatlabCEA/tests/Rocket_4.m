function data = Rocket_4()

reactants =   [                                           ...
             CEA.Reactant('C3H8',                            ...
                     'Type','Fuel',                     ...
                     'E',DimVar(-10000,'J/mol'),        ...
                     'T',DimVar(27,'C'),               ...         
                     'Q',DimVar(1,'kg'))                ...
            CEA.Reactant('H2O2(L)',                          ...
                    'Type','ox',                        ...
                    'T',DimVar(298,'K'),                ...         
                    'Q',DimVar(0.9,'kg'))               ...
            CEA.Reactant('H2O(L)',                           ...
                    'Type','ox',                        ...
                    'T',DimVar(298,'K'),                ...         
                    'Q',DimVar(0.1,'kg'))               ...
            ];     
        

data =  CEA.Run(reactants,                              ...
        'ProblemType','Rocket',                         ...
        'Flow','eq',                                    ...
        'CombLength','fac',                             ...
        'CR',2,                           ...
        'Pc',DimVar(500,'psi'),                         ...
        'OF',1,                                         ...
        'Outputs',{'isp'});
